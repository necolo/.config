# Standard-library-only UI regression check; temporary sessions are cleaned up.
# Run: python3 tests/check_keybindings.py
import fcntl
import json
import os
from pathlib import Path
import pty
import re
import select
import signal
import struct
import subprocess
import tempfile
import time
import sys

CONFIG = Path(__file__).resolve().parents[1] / 'config.kdl'
ZELLIJ = subprocess.check_output(['which', 'zellij'], text=True).strip()
F12 = b'\x1b[24~'

def collect(fd, duration=.7):
    end = time.monotonic() + duration
    output = bytearray()
    while time.monotonic() < end:
        if select.select([fd], [], [], min(.1, end - time.monotonic()))[0]:
            try:
                chunk = os.read(fd, 65536)
            except OSError:
                break
            if not chunk:
                break
            output.extend(chunk)
            if b'\x1b[c' in chunk:
                os.write(fd, b'\x1b[?1;2c')
    text = output.decode('utf-8', errors='replace')
    text = re.sub(r'\x1b\].*?(?:\x07|\x1b\\)', '', text, flags=re.S)
    text = re.sub(r'\x1bP.*?\x1b\\', '', text, flags=re.S)
    text = re.sub(r'\x1b\[[0-?]*[ -/]*[@-~]', '', text)
    return text

with tempfile.TemporaryDirectory(prefix='zellij-hints-test-') as tmp:
    tmp = Path(tmp)
    session = 'hints-test-' + str(os.getpid())
    config = CONFIG.read_text()
    config = config.replace('load_plugins {\n    zellij:link\n}', 'load_plugins {}')
    config += '\ndefault_shell "/bin/sh"\nshow_startup_tips false\nshow_release_notes false\nsupport_kitty_keyboard_protocol false\nsession_serialization false\nweb_server false\n'
    test_config = tmp / 'config.kdl'
    test_config.write_text(config)
    env = {k: v for k, v in os.environ.items() if not k.startswith('ZELLIJ')}
    env.update(TERM='xterm-256color', SHELL='/bin/sh', HOME=str(tmp), XDG_CACHE_HOME=str(tmp / 'cache'), XDG_RUNTIME_DIR=str(tmp / 'runtime'))
    (tmp / 'runtime').mkdir()
    pid, fd = pty.fork()
    if pid == 0:
        os.chdir(tmp)
        os.execve(ZELLIJ, [ZELLIJ, '--config', str(test_config), '--data-dir', str(tmp / 'data'), '--session', session], env)
    try:
        fcntl.ioctl(fd, __import__('termios').TIOCSWINSZ, struct.pack('HHHH', 35, 160, 0, 0))
        os.kill(pid, signal.SIGWINCH)
        startup = collect(fd, 3)
        if 'Alt' not in startup:
            print('FAIL: native status bar has no Alt hints at rest; unlock indicator:', 'UNLOCK' in startup)
            raise AssertionError('Alt hints missing in resting mode')
        print('PASS: native status bar shows Alt hints at rest')
        failures = []
        os.write(fd, F12)
        prefix = collect(fd)
        menu = all(label in prefix.upper() for label in ('PANE', 'TAB', 'RESIZE', 'MOVE', 'SEARCH', 'SESSION'))
        print('PREFIX MENU:', 'PASS' if menu else 'FAIL')
        if not menu: failures.append('prefix menu')
        os.write(fd, F12)
        canceled = collect(fd)
        assert 'Alt' in canceled, 'F12 cancellation failed'
        os.write(fd, F12 + b'\x1b')
        assert 'Alt' in collect(fd), 'Esc did not cancel the prefix menu'
        print('PASS: F12/F12 and F12/Esc both cancel the prefix menu')
        for key, label, hint in [('p','pane','Move'), ('t','tab','Change focus'), ('n','resize','Increase'), ('h','move','Switch Location'), ('s','scroll','Scroll'), ('o','session','Manager')]:
            os.write(fd, F12 + key.encode())
            rendered = collect(fd)
            ok = hint.lower() in rendered.lower()
            print(label.upper() + ' HINTS:', 'PASS' if ok else 'FAIL')
            if not ok: failures.append(label + ' hints')
            os.write(fd, F12)
            collect(fd)
        def pane_count():
            result = subprocess.check_output([ZELLIJ, '--config', str(test_config), '--session', session, 'action', 'list-panes', '--json'], env=env, text=True, timeout=5)
            data = json.loads(result)
            return len(data['panes'] if isinstance(data, dict) else data)

        before = pane_count()
        os.write(fd, F12 + b'pn')
        created = collect(fd, 2)
        assert pane_count() == before + 1, 'F12 -> p -> n did not create a pane'
        assert 'Alt' in created and 'INTERFACE LOCKED' not in created, 'New pane did not return to normal hints'
        print('PASS: F12 -> p -> n creates a pane and automatically returns to resting mode with Alt hints')

        before = pane_count()
        os.write(fd, F12 + b'tn')
        new_tab = collect(fd, 2)
        assert pane_count() > before and 'Alt' in new_tab, 'New tab creation/automatic exit failed'
        print('PASS: F12 -> t -> n creates a tab and automatically exits')

        before = pane_count()
        os.write(fd, F12 + b'px')
        closed = collect(fd, 2)
        assert pane_count() < before and 'Alt' in closed, 'Pane close/automatic exit failed'
        print('PASS: F12 -> p -> x closes a pane and automatically exits')

        before = pane_count()
        os.write(fd, b'\x1bn')
        alt_created = collect(fd, 2)
        assert pane_count() == before + 1 and 'Alt' in alt_created, 'Direct Alt+n failed'
        print('PASS: Alt+n directly creates a pane, keeping Alt hints')

        os.write(fd, b"printf 'PLAIN-pnt-ok\\n'\n")
        plain = collect(fd)
        assert 'PLAIN-pnt-ok' in plain, 'Normal letters were intercepted'
        print('PASS: normal letter input passes through to the shell')

        os.write(fd, F12 + b'pc')
        rename = collect(fd)
        assert 'RENAMING PANE' in rename and 'done' in rename.lower(), 'Rename guidance missing'
        os.write(fd, b'HINTCHECK\r')
        renamed = collect(fd)
        assert 'HINTCHECK' in renamed and 'Alt' in renamed, 'Rename completion failed'
        print('PASS: rename guidance appears; Enter completes rename and exits')

        os.write(fd, F12 + b'ss')
        search_entry = collect(fd)
        assert 'ENTERING SEARCH TERM' in search_entry and 'done' in search_entry.lower(), 'Search-entry guidance missing'
        os.write(fd, b'needle\r')
        search = collect(fd)
        assert 'SEARCHING' in search and 'Wrap' in search, 'Search-result guidance missing'
        os.write(fd, b'\x1b')
        left_search = collect(fd)
        assert 'Alt' in left_search, 'Esc did not finish searching'
        print('PASS: search entry/results show guidance; Esc exits')

        os.write(fd, F12 + b'n+')
        resizing = collect(fd)
        assert 'Increase' in resizing, 'Resize should stay active for continuous adjustment'
        os.write(fd, b'\r')
        finished = collect(fd)
        assert 'Alt' in finished, 'Enter did not finish continuous resize'
        print('PASS: continuous resizing retains hints; Enter exits without another F12')

        command = (sys.executable + " -c 'import os,tty,termios; old=termios.tcgetattr(0); tty.setraw(0); data=b\"\".join(os.read(0,1) for _ in range(5)); termios.tcsetattr(0,termios.TCSANOW,old); print(\"CTRL-BYTES:\"+repr(list(data)),flush=True)'\n").encode()
        os.write(fd, command)
        collect(fd)
        os.write(fd, bytes([16,20,15,14,7]))
        raw = collect(fd)
        assert 'CTRL-BYTES:[16, 20, 15, 14, 7]' in raw, 'Application did not receive all tested Ctrl keys: ' + repr(raw[-800:])
        print('PASS: application receives Ctrl+p/t/o/n/g unchanged')
        assert not failures, 'Native hint failures: ' + ', '.join(failures)
    finally:
        subprocess.run([ZELLIJ, '--config', str(test_config), 'kill-session', session], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5)
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        os.close(fd)
        deadline = time.monotonic() + 3
        while time.monotonic() < deadline:
            if os.waitpid(pid, os.WNOHANG)[0]:
                break
            time.sleep(.05)
        else:
            os.kill(pid, signal.SIGKILL)
            os.waitpid(pid, 0)
