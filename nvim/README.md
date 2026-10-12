# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

The terminal uses the default Snacks layout: a bottom split.

`<leader>jj` (Space, j, j) toggles JJUI in a floating Snacks terminal in
Neovim's current working directory. Requires `jj` and `jjui` on PATH and a
Jujutsu workspace. Input mode starts automatically; Snacks' double-Escape
mapping is disabled only in this window so Escape reaches JJUI. Press `q`
in JJUI's main view to exit and close the float.

Built-in spell checking is enabled by default for English; Chinese, Japanese,
and Korean characters are ignored (`spelllang=en,cjk`). In code files, the
syntax or Tree-sitter spelling regions determine which text is checked.

- `<leader>us`: toggle spell checking in the current window (the leader is Space).
- `]s` / `[s`: jump to the next / previous spelling error.
- `z=`: show corrections for the word under the cursor.
- `zg` / `zug`: add / remove a word from your personal dictionary.

## Harper

[Harper](https://writewithharper.com/docs/integrations/neovim) checks English
spelling and grammar locally through LSP. `harper-ls` is managed by Mason and
enabled in `lua/plugins/languages.lua` for its default filetypes, including
Markdown, Git commit messages, and comments in supported programming languages.

- `<leader>ca`: show corrections, ignore an error, or add a word to a Harper dictionary.
- `]d` / `[d`: jump to the next / previous diagnostic.
- `<leader>cm`: open Mason to manage the installed server.

Built-in spelling remains enabled independently: `z=` and `zg` use Neovim's
dictionary, not Harper's. `<leader>us` toggles only built-in spelling.

## Hunk

[Hunk](https://hunk.dev/docs/workflows/git-pager-and-difftool/) is an independent
terminal diff viewer installed with `brew install hunk`. The machine's global
Git configuration uses it as the default difftool:

```sh
git config --global diff.tool hunk
git config --global difftool.hunk.cmd 'hunk difftool "$LOCAL" "$REMOTE" "$MERGED"'
git config --global difftool.prompt false
```

In Lazygit's files or commits panel, `Ctrl+t` opens the selected diff in Hunk;
`q` exits back to Lazygit. Git invokes difftool per file. Run `hunk diff` directly
to review the full working-tree changeset. Git's normal pager is unchanged.
