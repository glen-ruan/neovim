$ErrorActionPreference = 'Stop'

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    throw 'uv is required: https://docs.astral.sh/uv/getting-started/installation/'
}

uv tool install --python 3.13 --force cmake-language-server
Write-Host 'cmake-language-server installed with an isolated Python 3.13 runtime'
