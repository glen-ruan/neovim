$ErrorActionPreference = 'Stop'

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    throw 'Neovim was not found in PATH.'
}

$configRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$initLua = Join-Path $configRoot 'init.lua'
$bootstrap = Join-Path $configRoot 'scripts\bootstrap.lua'

# -l skips user configuration, so -u must load init.lua explicitly. Installation
# and verification live in bootstrap.lua so Lua failures produce a nonzero exit code.
nvim --headless -i NONE -u $initLua -l $bootstrap
if ($LASTEXITCODE -ne 0) {
    Write-Error "Bootstrap failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

Write-Host 'Bootstrap complete. Run :checkhealth nvim_config in Neovim.'
