# Raz package demo

This project validates a registry dependency (`regex`) and includes a small deterministic native benchmark for comparing Raz code-generation backends.

Run it normally with `raz run`. The executable prints the regex smoke-test result followed by benchmark iterations, elapsed nanoseconds, nanoseconds per iteration, iterations per second, and a deterministic checksum.

On Windows, compare Forge and LLVM with:

```powershell
.\scripts\benchmark-backends.ps1 -Raz raz
```

Release mode is the default so runtime results compare optimized backends. Use `-Profile debug` when you specifically want debug-build behavior. The script performs a clean project build for each backend, prints build time and executable size, then runs the same in-binary workload.
