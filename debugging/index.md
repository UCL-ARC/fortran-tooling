---
title: Debugging
---

<!-- Doxygen config
@page debugging Debugging
-->


# Candidate Tools

| tool | description | Known issues |
| ---- | ----------- | ------------ |
| [GDB](https://www.sourceware.org/gdb/) | | |
| [linaro DDT](https://www.linaroforge.com/linaroDdt/) | | |
| [mdb](https://github.com/TomMelt/mdb) | A lightweight wrapper of [gdb](https://www.sourceware.org/gdb/) and [lldb](https://lldb.llvm.org/) intended to make debugging MPI a lot simpler. | <ul><li>Not compatible with Apple ARM.</li><li> Maintained by only one person</li></ul> |
| print statement | Great for small programs and simple problems but provides very limited information and requires recompiling to alter that information. We recommend spending the time to learn how to use a debugging tool such as the others in this list. | |

<!-- Doxygen config
**Subpages:** @subpage mdb
-->
