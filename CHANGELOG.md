# Changelog

## 1.0.1 - 2026-09-09

- Pin `pygls` 1.3.1 in the isolated CMake LSP installer so the server starts correctly.
- Prefer machine-local and uv-installed tools before Mason's fallback executables.

## 1.0.0 - 2026-09-09

- Unify Windows and Linux configuration on one branch.
- Add machine-local tool overrides without tracked absolute paths.
- Make optional language servers and debuggers fail gracefully.
- Keep CMake LSP independent from Mason's system Python.
- Add health checks, setup documentation, and cross-platform CI.
