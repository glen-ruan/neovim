$ErrorActionPreference = 'Stop'

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    throw 'Neovim was not found in PATH.'
}

nvim --headless -i NONE '+Lazy! restore' +qa
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

nvim --headless -i NONE '+MasonToolsInstallSync' +qa
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

nvim --headless -i NONE '+TSInstallConfigured!' +qa
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host 'Bootstrap complete. Run :checkhealth nvim_distribution in Neovim.'
