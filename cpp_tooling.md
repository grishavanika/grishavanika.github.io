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
	| % { clang-format.exe -i --style=file:.clang-format $_.FullName }
```

#### MSVC: dump class/object memory layout

See [/d1reportAllClassLayout – Dumping Object Memory Layout](https://ofekshilon.com/2010/11/07/d1reportallclasslayout-dumping-object-memory-layout/) and [VC++ 2013 class Layout Change and Wasted Space](https://randomascii.wordpress.com/2013/12/01/vc-2013-class-layout-change-and-wasted-space/). For this code:

```cpp {.numberLines}
// main.cpp
struct MyBase
{
	virtual ~MyBase() = default;
	virtual void MyFoo() {};
	int _data = -1;
};

struct MyDerived : MyBase
{
	virtual void MyFoo() override {};
	float _id = 0.0f;
};
```

Running

cl /d1reportSingleClassLayout[MyDerived]{.mark} main.cpp

will dump:


``` {.numberLines}
class MyDerived size(12):
        +---
 0      | +--- (base class MyBase)
 0      | | {vfptr}
 4      | | _data
        | +---
 8      | _id
        +---

MyDerived::$vftable@:
        | &MyDerived_meta
        |  0
 0      | &MyDerived::{dtor}
 1      | &MyDerived::MyFoo
```

Note there is also `/d1reportAllClassLayout` so you don't need to specify class name.
