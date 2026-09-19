# Changelog

## Unreleased

- Add global GitHub repository and code search through GitHub CLI and the Snacks picker, with remote code results opening as read-only Neovim buffers.
- Make GitHub Issue, pull request, and discussion shortcuts search across GitHub instead of requiring the current working directory to be a matching repository.
- Add safe buffer-local `q` and `<leader>q` mappings for Octo and remote GitHub buffers so closing a view cannot leave Neo-tree as the final window and exit Neovim.

## 2.0.0 - 2026-09-19

- Restrict `<leader>q` to regular editor buffers so an accidental quit mapping cannot close Neo-tree or another utility window.
- Add Octo with the Snacks picker for browsing GitHub repositories, issues, pull requests, discussions, notifications, and reviews inside Neovim.
- Standardize comments, notifications, prompts, and errors in non-documentation files on English, with a CI contract preventing regressions.
- Add a real-plugin runtime contract check covering documented commands and core, search, Git, DAP, LSP, formatting, Quarto, and terminal keymaps.
- Keep hover and signature help as passive, non-focusable floating windows that close on cursor movement, without a `q`-to-close interaction.
- Restore `:LspInfo` on Neovim 0.12 as a compatibility alias for the native `:checkhealth vim.lsp` report.
- Preserve complete single-plugin specs when aggregating plugin modules, including Snacks, Aerial, rename, completion, diagnostics, writing, and scrolling configuration.
- Restrict the manual horizontal and vertical split mappings to normal editor buffers, preventing accidental splits from file trees and other utility windows.
- Move runtime code into the `nvim_config` namespace with separate core, feature, integration, and plugin-spec modules.
- Keep the root `init.lua` as a stable one-line entry point and load IAR/Keil integrations only on Windows.
- Add startup-time `:LspAvailability`, restore documented Python overrides, and remove tracked executable-location fallbacks.
- Replace repository-centric documentation with user guides for installation, configuration, dependencies, keymaps, embedded development, troubleshooting, and contribution.
- Add repository path-leak, Markdown-link, settings-schema, startup-command, startup-mapping, and plugin-spec checks to cross-platform CI.
- Rename the custom health provider to `:checkhealth nvim_config`.

## 1.0.8 - 2026-09-14

- Show the configuration version in the statusline and add `:ConfigVersion` (version, branch and commit), so it is obvious which release a machine is running.
- Add `:ConfigChangelog` to read the changelog in a floating window (`q` or `<Esc>` closes it).
- Restore the word / line / bracket selection shortcuts as `<leader>vc`, `<leader>vl` and `<leader>vv`, which leaves `v` followed by `c`, `l` or `v` free for the native commands.
- Document the new commands and selection shortcuts in the shortcut guide.

## 1.0.7 - 2026-09-14

- Disable completion in `markdown` buffers. Prose has nothing worth completing, and turning the plugin off for the filetype also returns `<Tab>` to plain indentation.
- In `quarto` buffers, keep completion but auto-show the menu only inside fenced code blocks (detected with Treesitter). Prose stays quiet while code chunks keep completing, and `<C-space>` still triggers completion manually anywhere.

## 1.0.6 - 2026-09-12

- Treat `ripgrep` as a required dependency instead of optional search acceleration: `Snacks.picker.grep()` hardcodes `rg` with no fallback, so a missing one breaks the `空格 f g` keymap.
- Report a missing `rg` as an error in `:checkhealth nvim_distribution` with the install command, and note that Mason does not provide the package.
- Say what actually breaks in the bootstrap hints: a missing `rg` disables grep, while a missing `fd` only falls back to a slower file search.
- Clarify in the README that `fdfind` alone already enables file and project search, and that the `fd` symlink is for the health check and `Snacks.picker.explorer()`.

## 1.0.5 - 2026-09-12

- Check the LaTeX toolchain (`latexmk`, `xelatex`) and the Chinese typesetting packages (`ctex` / `xeCJK`) in `:checkhealth nvim_distribution`, with the install command in the advice.
- Verify the `tree-sitter` CLI version (0.26.1+) instead of only its presence, since a missing or outdated CLI stays invisible until `:TSInstallConfigured!` fails.
- List missing optional dependencies at the end of the bootstrap without turning them into a failure.
- Document how to install the optional LaTeX toolchain, `tree-sitter-cli` (with the nvm caveat) and `fd` (renamed to `fdfind` on Debian/Ubuntu).
- Document that LaTeX compilation runs with `-shell-escape`, so only trusted documents should be compiled.
- Explain Lazy's `Clean` list, the `import` requirement for new plugin specs, and that `:Lazy update` rewrites `lazy-lock.json`.

## 1.0.4 - 2026-09-12

- Enable the LaTeX toolchain (VimTeX + tex-fmt) and keep latexindent's log and backups out of the working directory.
- Drop the unused `header.nvim` spec that was never imported.
- Free the native `gr*` LSP mappings by moving the references picker to `grr`, and add `<leader>ca` for code actions.
- Use aerial's supported `guides` keys instead of the nonexistent `guide_chars`.
- Remove keymaps that shadowed core Vim behavior (`vc`/`vv`/`vl`, `dw`, `<C-f>`, `<C-a>`, `<C-c>`, `<C-v>`, `p`); terminal `Esc` now takes a double press.
- Make the bootstrap scripts exit non-zero when a step fails, and verify Mason tools and Treesitter parsers after installing them.
- Add tool directories to `PATH` even before Mason creates them.
- Put the clangd compatibility headers last so they no longer shadow toolchain headers.
- Disable the lazy bytecode cache on Windows only, where the cache lives under `%TEMP%`.
- Cover `scripts/` in the CI Lua syntax check, so the bootstrap script is verified on every push.

## 1.0.3 - 2026-09-09

- Restore the pre-debug split sizes and focused window when `F6` closes DAP.
- Bind Pyright and Python debugging to the nearest project `.venv` without falling back to global packages.
- Report missing Python imports as errors and refresh Pyright after selecting the project interpreter.
- Load tiny-inline-diagnostic before LSP attachment and keep diagnostics visible across mode changes.

## 1.0.2 - 2026-09-09

- Keep Python stdout and stderr in the DAP REPL after short programs finish.
- Keep the debug panels open until the user closes them with `F6` or `<leader>du`.

## 1.0.1 - 2026-09-09

- Pin `pygls` 1.3.1 in the isolated CMake LSP installer so the server starts correctly.
- Prefer machine-local and uv-installed tools before Mason's fallback executables.

## 1.0.0 - 2026-09-09

- Unify Windows and Linux configuration on one branch.
- Add machine-local tool overrides without tracked absolute paths.
- Make optional language servers and debuggers fail gracefully.
- Keep CMake LSP independent from Mason's system Python.
- Add health checks, setup documentation, and cross-platform CI.
