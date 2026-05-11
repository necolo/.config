# SketchyBar Configuration

Lua-based SketchyBar with AeroSpace integration via direct socket communication.

## Setup on New Machine

```bash
# 1. Copy config
cp -r ~/.config/sketchybar /path/to/new/machine/

# 2. Install dependencies
cd ~/.config/sketchybar
./install_dependencies.sh

# 3. Grant Accessibility permissions
# System Settings → Privacy & Security → Accessibility → Add Terminal

# 4. Start
brew services start sketchybar
```

## Dependencies Installed

### Homebrew packages
- lua, luarocks
- sketchybar
- switchaudio-osx, nowplaying-cli

### Fonts
- SF Symbols, SF Pro, SF Mono
- Hack Nerd Font
- sketchybar-app-font

### Lua modules (via luarocks)
- lua-cjson (JSON parsing)
- luaposix (socket APIs)

### Compiled binaries
- SbarLua (`~/.local/share/sketchybar_lua/`)
- C helpers (`helpers/menus/bin/`, `helpers/event_providers/*/bin/`)

## Structure

```
├── sketchybarrc           # Entry point, loads Lua paths
├── init.lua               # Main config loader
├── bar.lua                # Bar appearance
├── colors.lua, icons.lua  # Theme resources
├── items/                 # Bar items
│   ├── workspaces.lua     # AeroSpace integration (AeroSpaceLua)
│   ├── battery.lua
│   ├── calendar.lua
│   └── media.lua
└── helpers/
    ├── aerospace.lua      # AeroSpaceLua module
    ├── app_icons.lua      # Icon mappings
    └── menus/             # C helpers
```

## Hot Reload

Edit `.lua` files → auto-reload (~100ms)

Manual: `sketchybar --reload`

## Performance (AeroSpaceLua)

Direct socket vs CLI:
- Query workspaces: 30-50ms → 5-10ms (5-10x faster)
- List windows: 30-50ms → 5-10ms (5-10x faster)

## Troubleshooting

```bash
# Check running
pgrep -f sketchybar

# View logs
tail -f /tmp/sketchybar_$USER.log

# Reinstall Lua deps
luarocks install lua-cjson luaposix --local

# Recompile C helpers
cd helpers/menus && make clean && make
```

## Rollback

```bash
cp items/workspaces.lua.backup items/workspaces.lua
brew services restart sketchybar
```
