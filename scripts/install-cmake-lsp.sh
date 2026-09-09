#!/usr/bin/env sh
set -eu

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required: https://docs.astral.sh/uv/getting-started/installation/" >&2
  exit 1
fi

uv tool install --python 3.13 --force cmake-language-server
echo "cmake-language-server installed with an isolated Python 3.13 runtime"
