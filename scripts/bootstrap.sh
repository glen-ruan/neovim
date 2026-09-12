#!/usr/bin/env sh
set -eu

if ! command -v nvim >/dev/null 2>&1; then
  echo "Neovim was not found in PATH." >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_root=$(dirname -- "$script_dir")

# -l 会跳过用户配置，所以必须同时用 -u 指定 init.lua；安装与校验都在
# scripts/bootstrap.lua 里完成，只有 -l 模式才会因 Lua 错误返回非零退出码。
if ! nvim --headless -i NONE -u "$config_root/init.lua" -l "$script_dir/bootstrap.lua"; then
  echo "Bootstrap failed." >&2
  exit 1
fi

echo "Bootstrap complete. Run :checkhealth nvim_distribution in Neovim."
