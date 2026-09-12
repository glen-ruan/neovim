$ErrorActionPreference = 'Stop'

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    throw 'Neovim was not found in PATH.'
}

$configRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$initLua = Join-Path $configRoot 'init.lua'
$bootstrap = Join-Path $configRoot 'scripts\bootstrap.lua'

# -l 会跳过用户配置，所以必须同时用 -u 指定 init.lua；安装与校验都在
# scripts/bootstrap.lua 里完成，只有 -l 模式才会因 Lua 错误返回非零退出码。
nvim --headless -i NONE -u $initLua -l $bootstrap
if ($LASTEXITCODE -ne 0) {
    Write-Error "Bootstrap failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

Write-Host 'Bootstrap complete. Run :checkhealth nvim_distribution in Neovim.'
