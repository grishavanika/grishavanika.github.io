---
title: C++ snippets
---

### add a value into sorted vector, trivial case

```cpp {.numberLines}
#include <vector>
#include <algorithm>

void Sorted_Add(std::vector<int>& vs, int v)
{
    auto it = std::upper_bound(vs.begin(), vs.end(), v);
    vs.insert(it, v);
}
```

Note, in case of no duplicates, the use of `std::lower_boud()` brings no difference,
i.e., this is the same as above:

```cpp {.numberLines}
void Sorted_Add(std::vector<int>& vs, int v)
{
    auto it = std::lower_bound(vs.begin(), vs.end(), v);
    vs.insert(it, v);
}
```

In case of duplicates, std::upper_bound or std::lower_bound still could be used,
however, std::upper_bound inserts new value to the end of duplicate values range,
std::lower_bound inserts new value before duplicate values range:

``` {.numberLines}
{1, 5, 5, 5, 9}        // initial
{1, 5, 5, 5, **5**, 9} // std::upper_bound(..., 5)
{1, **5**, 5, 5, 5, 9} // std::lower_bound(..., 5)
```

The difference could be important in case of (a) many duplicates --
std::upper_bound, in theory, requires less swaps for a later insert and (b) when
custom type/struct is used with custom predicate/sort by field -- so insert
position is observable.

See [this SO](https://stackoverflow.com/a/25524075) and [std::upper_bound](https://en.cppreference.com/w/cpp/algorithm/upper_bound).

[General note:]{.mark}

Here (and everywhere else), `int` type is used as a placeholder, meaning that
templated version could look like this:

```cpp {.numberLines}
#include <vector>
#include <algorithm>

template<typename T>
void Sorted_Add(std::vector<T>& vs, T v)
{
	auto it = std::upper_bound(vs.begin(), vs.end(), v);
	vs.insert(it, std::move(v));
}
```

or this, depending on the needs (note on additional typename U and std::forward):

```cpp {.numberLines}
#include <vector>
#include <algorithm>

template<typename T, typename U>
void Sorted_Add(std::vector<T>& vs, U&& v)
{
	auto it = std::upper_bound(vs.begin(), vs.end(), v);
	vs.insert(it, std::forward<U>(v));
}
```

### parse string to int, strict version

```cpp {.numberLines}
#include <string_view>
#include <charconv>
#include <cassert>
#include <cstdint>

std::uint64_t ParseToU64(const std::string_view& str)
{
	std::uint64_t v = 0;
	const char* const start = str.data();
	const char* const end = (start + str.size());
	auto&& [ptr, ec] = std::from_chars(start, end, v, 10);
	assert(ptr == end);
	assert(ec == std::errc{});
	return v;
}
```

where it does not allow to have string leftovers, so `ParseToU64("10a")` fails,
compared to regular `std::from_chars("10a", ...)` and old-style `atoi("10a")`
analogs.

### custom assert pre-C++23

```cpp {.numberLines}
#define KK_ABORT(KK_FMT, ...) (void)                              \
    (::log_abort(__FILE__, __LINE__, KK_FMT, ##__VA_ARGS__),      \
        __debugbreak(),       /*MSVC-specific*/                   \
        std::quick_exit(-1))  /*just to be extra-paranoid*/

#define KK_VERIFY(KK_EXPRESSION) (void)                           \
    (!!(KK_EXPRESSION) ||                                         \
        (KK_ABORT("Verify failed: '%s'.", #KK_EXPRESSION), false))

#define KK_ASSERT KK_VERIFY // another name

#include <cstdarg>
#include <cstdio>
#include <cstdlib>

void log_abort(const char* file, unsigned line, const char* fmt, ...)
{
    char str[1024]{};
    va_list args;
    va_start(args, fmt);
    (void)std::vsnprintf(str, std::size_t(str), fmt, args);
    va_end(args);

    // Optionally, only file name could be cut and used from `file`.
    (void)std::fflush(stdout);
    (void)std::fprintf(stderr, "Error at '%s,%u'\n -> %s\n", file, line, str);
    (void)std::fflush(stderr);
}

int main(int argc, char* argv)
{
    KK_ASSERT(argc == 2 && "Test requires 1 argument");
}
```

prints:

``` {.numberLines}
Error at '...\main.cpp,32'
 -> Verify failed: 'argc == 2 && "Test requires 1 argument"'.
```

### custom assert post-C++23, with callstack

```cpp {.numberLines}
#define KK_ABORT(KK_FMT, ...) (void)                             \
    (::log_abort(__FILE__, __LINE__, KK_FMT,                     \
        std::make_format_args(__VA_ARGS__)),                     \
            __debugbreak(),       /*MSVC-specific*/              \
            std::quick_exit(-1))  /*just to be extra-paranoid*/

#define KK_VERIFY(KK_EXPRESSION) (void)                           \
    (!!(KK_EXPRESSION) ||                                         \
        (KK_ABORT("Verify failed: '{}'.", #KK_EXPRESSION), false))

#define KK_ASSERT KK_VERIFY // another name

#include <format>
#include <print>
#include <stacktrace>

void log_abort(const char* file, unsigned line
    , const char* fmt, std::format_args args)
{
    char str[1024]{};
    std::vformat_to(str, fmt, std::move(args));
    (void)std::fflush(stdout);
    std::println(stderr, "Error at '{},{}'\n -> {}", file, line, str);
    std::println(stderr, "---- Callstack:\n{}", std::stacktrace::current());
    (void)std::fflush(stderr);
}

int main(int argc, char* argv)
{
    KK_ASSERT(argc == 2 && "Test requires 1 argument");
}
```

prints:

``` {.numberLines}
Error at '...\main.cpp,30'
 -> Verify failed: 'argc == 2 && "Test requires 1 argument"'.
---- Callstack:
0> ...\main.cpp(24): snippets!log_abort+0x1BC
1> ...\main.cpp(30): snippets!main+0xCA
2> ...\exe_common.inl(79): snippets!invoke_main+0x39
3> ...\exe_common.inl(288): snippets!__scrt_common_main_seh+0x12E
4> ...\exe_common.inl(331): snippets!__scrt_common_main+0xE
5> ...\exe_main.cpp(17): snippets!mainCRTStartup+0xE
6> KERNEL32!BaseThreadInitThunk+0x17
7> ntdll!RtlUserThreadStart+0x2C
```

-----------------------------------------------------------

C++ snippets:

 * sorted add/remove/find for int/trivial type
 * sorted add/remove/find for struct/custom predicates, by given field
 * sorted iterate by group for custom struct
 * parse to double/int
 * io completion port
 * readdirectorychanges
 * basic threadpool
 * basic threadpool with work stealing
 * read file c-api
 * read file c++-api
 * read huge file (> 4 GBs)
 * read file winapi
 * read file mmap
 * read file async
