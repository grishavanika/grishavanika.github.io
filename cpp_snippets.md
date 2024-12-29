---
title: C++ snippets
---

#### sorted vector: add a value into sorted vector, trivial case

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
