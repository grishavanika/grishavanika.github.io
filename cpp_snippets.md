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

### validate printf format at compile time

```cpp {.numberLines}
#include <cstdio>
// GCC, Clang: -Werror=format
// GCC, Clang: error: format specifies type 'char *' but the argument has type 'int' [-Werror,-Wformat]
// MSVC: /we4477
// MSVC: error C4477: 'printf' : format string '%s' requires an argument of type 'char *', but variadic argument 1 has type 'int'
#define KK_CHECK_PRINTF(KK_FMT, ...) (void) \
    (false && \
        std::printf(KK_FMT, ##__VA_ARGS__))
```

`KK_CHECK_PRINTF("%s", 10)` will fail to compile (/we4477 for MSVC, -Werror=format
for GCC, Clang). This relies on the fact that `std::printf` is validated by all
compilers. There are ways to achieve similar effect for custom printf functions
by using SAL Annotations for MSVC (see this [SO](https://stackoverflow.com/a/6849629))
and `__attribute__((format(printf, 1, 2)))` for GCC/Clang. However, using printf
directly is the easiest way.

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

### custom assert, std::printf-based (<=C++17), simplest (?)

 * with enabled printf format validation on GCC with `-Werror=format`, need to silence
   one other warning with `-Wno-format-zero-length` caused by `KK_VERIFY(false)`

Sample:

``` {.numberLines}
KK_VERIFY(false);
KK_VERIFY(false, "message");
KK_VERIFY(false, "message %s %s", "format", "args");
```

Code:

```cpp {.numberLines}
#include <cstdio>  // for std::printf validation
#include <cstdlib> // std::abort()

#define KK_CHECK_PRINTF(...) (void)     \
    (false && std::printf(__VA_ARGS__))

#define KK_VERIFY(KK_EXPRESSION, ...) (void)      \
    (!!(KK_EXPRESSION) ||                         \
        (::detail::dump_verify(__FILE__, __LINE__ \
            , #KK_EXPRESSION, ##__VA_ARGS__)      \
        , KK_CHECK_PRINTF("" __VA_ARGS__)         \
        , KK_DEBUGBREAK()                         \
        , KK_EXIT()                               \
        , false)                                  \
    )

#define KK_DEBUGBREAK() \
    __debugbreak() /* MSVC-specific */
#define KK_EXIT() \
    std::abort() /* OR std::quick_exit(-1)*/

#include <cstdarg> // va_list

namespace detail
{
    void dump_verify(const char* file, unsigned line, const char* expression, const char* fmt, ...)
    {
        char str[1024]; // not initialized, vsnprintf zero-terminates
        va_list args;
        va_start(args, fmt);
        (void)std::vsnprintf(str, std::size_t(str), fmt, args);
        va_end(args);
        // flush stdout if needed
        (void)std::fprintf(stderr, "Verify '%s' failed at '%s,%u' -> %s\n"
            , expression, file, line, str);
    }

    void dump_verify(const char* file, unsigned line, const char* expression)
    {
        // flush stdout if needed
        (void)std::fprintf(stderr, "Verify '%s' failed at '%s,%u'\n"
            , expression, file, line);
    }
} // namespace detail
```

### custom assert, std::printf-based (<=C++17), ALT

 * with std::printf format & args validation
 * with overload for optional message and or custom format
 * up to 15 custom args, modify KK_SELECT_N() to support more
 * `__VA_OPT__` could be used to simplify KK_SELECT_N machinery, see [Making a flexible assert in C++](https://www.dominikgrabiec.com/c++/2023/02/28/making_a_flexible_assert.html)

Sample:

``` {.numberLines}
KK_VERIFY(false);
KK_VERIFY(false, "message");
KK_VERIFY(false, "message %s %s", "format", "args");
```

Code:

```cpp {.numberLines}
#include <cstdio>  // for std::printf validation
#include <cstdlib> // std::abort()

#define KK_CHECK_PRINTF(KK_FMT, ...) (void) \
    (false && \
        std::printf(KK_FMT, ##__VA_ARGS__))

// Based on GET_MACRO() from https://stackoverflow.com/questions/11761703/overloading-macro-on-number-of-arguments/69945225#69945225
#define KK_EXPAND(x) x
#define KK_SELECT_N(      \
      _1,  _2,  _3,  _4   \
    , _5,  _6,  _7,  _8   \
    , _9, _10, _11, _12   \
    , _13, _14, _15, _16  \
    , NAME, ...) NAME

#define KK_VERIFY(...)                                              \
    KK_EXPAND(KK_SELECT_N(__VA_ARGS__                               \
        , KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F        \
        , KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F        \
        , KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F        \
        , KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_EXPR)    \
    (__VA_ARGS__))

#define KK_DEBUGBREAK() \
    __debugbreak() /* MSVC-specific */
#define KK_EXIT() \
    std::abort() /* OR std::quick_exit(-1)*/

#define KK_VERIFY_EXPR(KK_EXPRESSION) (void)                        \
    (!!(KK_EXPRESSION) ||                                           \
        (::detail::dump_verify(__FILE__, __LINE__, #KK_EXPRESSION)  \
        , KK_DEBUGBREAK()                                           \
        , KK_EXIT()                                                 \
        , false)                                                    \
    )

#define KK_VERIFY_F(KK_EXPRESSION, KK_FMT, ...) (void)      \
    (!!(KK_EXPRESSION) ||                                   \
        (::detail::dump_verify(__FILE__, __LINE__           \
            , #KK_EXPRESSION, KK_FMT, ##__VA_ARGS__)        \
        , KK_CHECK_PRINTF(KK_FMT, ##__VA_ARGS__)            \
        , KK_DEBUGBREAK()                                   \
        , KK_EXIT()                                         \
        , false)                                            \
    )

#include <cstdarg> // va_list

namespace detail
{
    void dump_verify(const char* file, unsigned line, const char* expression, const char* fmt, ...)
    {
        char str[1024]; // not initialized, vsnprintf zero-terminates
        va_list args;
        va_start(args, fmt);
        (void)std::vsnprintf(str, std::size_t(str), fmt, args);
        va_end(args);
        // flush stdout if needed
        (void)std::fprintf(stderr, "Verify '%s' failed at '%s,%u' -> %s\n"
            , expression, file, line, str);
    }

    void dump_verify(const char* file, unsigned line, const char* expression)
    {
        // flush stdout if needed
        (void)std::fprintf(stderr, "Verify '%s' failed at '%s,%u'\n"
            , expression, file, line);
    }
} // namespace detail
```

### custom assert, std::format-based (>=C++20)

 * with std::format
 * with overload for optional message and or custom format
 * up to 15 custom args, modify KK_SELECT_N() to support more
 * `__VA_OPT__` could be used to simplify KK_SELECT_N machinery, see [Making a flexible assert in C++](https://www.dominikgrabiec.com/c++/2023/02/28/making_a_flexible_assert.html)

Sample:

``` {.numberLines}
KK_VERIFY(false);
KK_VERIFY(false, "message");
KK_VERIFY(false, "message {} {}", "format", "args");
```

Code:

```cpp {.numberLines}
#include <cstdlib> // std::abort()
#include <print>

// Based on GET_MACRO() from https://stackoverflow.com/questions/11761703/overloading-macro-on-number-of-arguments/69945225#69945225
#define KK_EXPAND(x) x
#define KK_SELECT_N(      \
      _1,  _2,  _3,  _4   \
    , _5,  _6,  _7,  _8   \
    , _9, _10, _11, _12   \
    , _13, _14, _15, _16  \
    , NAME, ...) NAME

#define KK_VERIFY(...)                                              \
    KK_EXPAND(KK_SELECT_N(__VA_ARGS__                               \
        , KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F        \
        , KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F        \
        , KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F        \
        , KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_F, KK_VERIFY_EXPR)    \
    (__VA_ARGS__))

#define KK_DEBUGBREAK() \
    __debugbreak() /* MSVC-specific */
#define KK_EXIT() \
    std::abort() /* OR std::quick_exit(-1)*/

#define KK_VERIFY_EXPR(KK_EXPRESSION) (void)                        \
    (!!(KK_EXPRESSION) ||                                           \
        (::detail::dump_verify(__FILE__, __LINE__, #KK_EXPRESSION)  \
        , KK_DEBUGBREAK()                                           \
        , KK_EXIT()                                                 \
        , false)                                                    \
    )

#define KK_VERIFY_F(KK_EXPRESSION, KK_FMT, ...) (void)      \
    (!!(KK_EXPRESSION) ||                                   \
        (::detail::dump_verify(__FILE__, __LINE__           \
            , #KK_EXPRESSION                                \
            , std::format_to_n(::detail::FormatBuffer{}.it()\
                , ::detail::FormatBuffer::available_size()  \
                , KK_FMT, ##__VA_ARGS__))                   \
        , KK_DEBUGBREAK()                                   \
        , KK_EXIT()                                         \
        , false)                                            \
    )

#include <cstring> // optional, for prettify_filename()

namespace detail
{
    // Workaround to the fact that std::make_format_args(10, 'c') does not compile
    // since it requires lvalue references (see http://wg21.link/P2905R2),
    // hence std::format_to_n() is used.
    struct FormatBuffer
    {
        FormatBuffer(const FormatBuffer&) noexcept = delete;
        FormatBuffer& operator=(const FormatBuffer&) noexcept = delete;

        static constexpr unsigned BUFFER_SIZE = 1024;
        char _buffer[BUFFER_SIZE]; // not initialized
        FormatBuffer() noexcept {}

        static constexpr std::ptrdiff_t available_size()
        {
            return BUFFER_SIZE - 1;
        }

        struct iterator
        {
            FormatBuffer* _self;
            char* _it;

            using difference_type = std::ptrdiff_t;

            iterator& operator++() noexcept
            {
                ++_it;
                return *this;
            }
            iterator operator++(int) noexcept
            {
                iterator copy{ *this };
                ++_it;
                return copy;
            }
            char& operator*() noexcept
            {
                return *_it;
            }
            static std::ptrdiff_t my_min(std::ptrdiff_t v1, std::ptrdiff_t v2)
            {
                return ((v1 < v2) ? v1 : v2);
            }
            void finish(std::ptrdiff_t size)
            {
                const std::ptrdiff_t p = my_min(size, FormatBuffer::available_size());
                _self->_buffer[p] = '\0';
            }
            const char* str() const
            {
                return _self->_buffer;
            }
        };

        iterator it()
        {
            return {this, _buffer};
        }

        using format_result = std::format_to_n_result<iterator>;
    };

    void dump_verify(const char* file, unsigned line, const char* expression, FormatBuffer::format_result&& fmt)
    {
        fmt.out.finish(fmt.size);
        // flush stdout if needed
        std::println(stderr, "Verify '{}' failed at '{},{}' -> {}"
            , expression, file, line, fmt.out.str());
        // C++23 - use std::stacktrace::current() if needed

    }

    void dump_verify(const char* file, unsigned line, const char* expression)
    {
        // flush stdout if needed
        std::println(stderr, "Verify '{}' failed at '{},{}'"
            , expression, file, line);
        // C++20 - do std::cerr << std::format(...) instead of std::println()
        // C++23 - use std::stacktrace::current() if needed
    }
} // namespace detail
```
