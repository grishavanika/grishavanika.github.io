---
title: C++ notes around tooling
---

#### clang-format, force multi-line formatting

Add `// ` comment at the end of line to force clang-format to NOT merge
everything into single line. This:

``` cpp {.numberLines}
const int status = ...;
if ((status == e1) || (status == e2) || other_error)
{
	HandleMe();
}
```

becomes:

``` cpp {.numberLines}
const int status = ...;
if ((status == e1)    //
	|| (status == e2) //
	|| other_error)
{
	HandleMe();
}
```

#### initial clang-format setup

 * Note clang-format version with `clang-format.exe --version`.
 * Dump some (any?) available style to .clang-format with `clang-format.exe --style=Microsoft --dump-config > .clang-format`.
 * (You may want to force everyone to use same clang-format version).
 * (Check [ClangFormatStyleOptions](https://clang.llvm.org/docs/ClangFormatStyleOptions.html) reference).

Add header with above info to .clang-format, submit:

``` {.numberLines}
# clang-format version 18.1.8
# clang-format.exe --style=Microsoft --dump-config > .clang-format
---
Language:        Cpp
# BasedOnStyle:  Microsoft
...
```

#### disable clang-format for piece of code

``` cpp {.numberLines}
// clang-format off
MyHandle(56
    , "args"
    , "data"
    );
// clang-format on
```

#### clang-format command line for file formatting

Single file:

``` {.numberLines}
clang-format.exe -i --style=file:.clang-format "main.cpp"
```

Folder:

``` {.numberLines}
ls -Path . -Recurse -File -Include *.h,*.cpp `
	| % { clang-format -i --style=file:.clang-format $_.FullName }
```
