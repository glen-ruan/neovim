#!/usr/bin/env sh
set -eu

if ! command -v nvim >/dev/null 2>&1; then
  echo "Neovim was not found in PATH." >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_root=$(dirname -- "$script_dir")

# -l skips user configuration, so -u must load init.lua explicitly. Installation
# and verification live in bootstrap.lua so Lua failures produce a nonzero exit code.
if ! nvim --headless -i NONE -u "$config_root/init.lua" -l "$script_dir/bootstrap.lua"; then
  echo "Bootstrap failed." >&2
  exit 1
fi

echo "Bootstrap complete. Run :checkhealth nvim_config in Neovim."
