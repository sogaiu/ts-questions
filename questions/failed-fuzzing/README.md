# Fuzzing an External Scanner

With libFuzzer, any external scanner can be fuzzed to detect buffer overflows,
memory leaks, infinite loop bugs and more.
The script here supports both C and C++, just run it as is.
If your scanner detects a bug, it can be hard to track down and fix —
you can also use lldb (for crashes, segfaults, etc) or valgrind
(for memory leaks and overflows) to help out even further.
