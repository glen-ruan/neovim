#!/usr/bin/env sh
set -eu

if ! command -v nvim >/dev/null 2>&1; then
  echo "Neovim was not found in PATH." >&2
  exit 1
fi

nvim --headless -i NONE '+Lazy! restore' +qa
nvim --headless -i NONE '+MasonToolsInstallSync' +qa
nvim --headless -i NONE '+TSInstallConfigured!' +qa

echo "Bootstrap complete. Run :checkhealth nvim_distribution in Neovim."
