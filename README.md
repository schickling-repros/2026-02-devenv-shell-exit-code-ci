# devenv - nested shell can swallow task failures in CI mode

`devenv shell` can return exit code `0` even when the nested `devenv tasks run` command fails.

## Reproduction

```bash
bash repro.sh
```

## Expected

The nested command should propagate the non-zero exit code from `devenv tasks run test:fail`.

## Actual

With `CI=true` and `DEVENV_TUI=false`, the nested command can return `0` while still printing:

```text
Error:   × Some tasks failed
```

## Versions

- devenv: `2.0.0+53faf7a`
- Runtime: `GNU bash, version 5.3.9(1)-release`
- OS: `Darwin 25.2.0 (aarch64)`

## Related Issue

TBD
