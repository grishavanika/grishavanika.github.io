---
title: C++ tips, tricks and quirks.
---

To generate .html:

```
pandoc -s --toc --toc-depth=4 ^
  --number-sections ^
  --highlight=kate ^
  cpp_tips_tricks_quirks.md ^
  -o cpp_tips_tricks_quirks.html 
```

-----------------------------------------------------------

[TODO]{.mark}

- base template classes and the need for this-> or Base
- #line and file renaming
- =default on implementation
- =delete for free functions
- friend injection
- (go thru idioms, shwartz counter, https://en.m.wikibooks.org/wiki/More_C++_Idioms)
- (go thru shortcuts, like immediately invoked lambda)
- see also https://github.com/shafik/cpp_blogs quiz questions
- (and https://cppquiz.org/)
- identity to disable template argument deduction
- hierarhical tag dispatch (see artur, https://quuxplusone.github.io/blog/2021/07/09/priority-tag/)
- cout and stdout synchronization
- initializer list crap (no move only)
- std::function crap (no move only)
- shared_ptr aliasing ctor
- shared_ptr delete base, no need for virtual
- non-trivial types in union
- +\[]()
- no capture needed for globals/const for lambda
- extern template
- operator-> and non pointer return type recursion
- operator Type for perfect forward construction
- overload struct for variant visit (inherit from lambda)
- pseudo destructors (~int)
- reference collapsing (even pre c++11)
- map and modifying keys ub
- picewise construct
- map[x]
- emplace back with placement new pre c++11
- unreal conditionaldestroy uobject
- unreal assign null (??)
- instanced structs
- const_cast mayers
- mayers singletong
- universal references, mayers
- https://gist.github.com/fay59/5ccbe684e6e56a7df8815c3486568f01
- https://jorenar.com/blog/less-known-c
- http://www.danielvik.com/2010/05/c-language-quirks.html
- https://codeforces.com/blog/entry/74684
- inherit multiple classes from template, with tags
- variadic templates default argument emulation
- mixing variadic templates and variadic c
- type promotion passing custom type/float to variadic c
- shared_ptr void
- dynamic_cast void
- dynamic cast reference/pointer
- https://andreasfertig.blog/2021/07/cpp20-a-neat-trick-with-consteval/
- templates sfinae/enable_if/checks/void_t
- https://en.cppreference.com/w/cpp/meta
- https://landelare.github.io/2023/01/07/cpp-speedrun.html
- https://andreasfertig.com/courses/programming-with-cpp11-to-cpp17/
- x-macro
- https://www.foonathan.net/2020/05/fold-tricks/
- rdbuf, read whole file
- rdbuf, redirect: https://stackoverflow.com/questions/10150468/how-to-redirect-cin-and-cout-to-files
- allocconsole, reopen
- https://chromium.googlesource.com/chromium/src/base/+/master/strings/stringprintf.h
- see chromium/base
- see boost/base
- see abseil
- forcing constexpr to be compile time
- type id / magic enum (parsing `__PRETTY_FUNCTION__`)

-----------------------------------------------------------

[TODO Unreal]{.mark}

- https://erikbern.com/2024/09/27/its-hard-to-write-code-for-humans.html
- https://itscai.us/blog/post/ue-physics-framework/
- https://github.com/mtmucha/coros
- https://achavezmixco.com/blog/f/how-to-write-c-blueprint-friendly-code-in-unreal-engine
- https://isaratech.com/all-articles/
- https://jasperdelaat.com/unreal-engine/damage-1/
- https://github.com/landelare/ue5coro
- https://landelare.github.io/2022/09/27/tips-and-tricks.html
- https://zomgmoz.tv/unreal/Unreal-Insights
- https://www.stevestreeting.com/2021/09/14/ue4-editor-visualisation-helper/
- https://www.stevestreeting.com/2020/11/02/ue4-c-interfaces-hints-n-tips/
- https://www.foonathan.net/2020/05/fold-tricks/
- https://tamir.dev/posts/that-overloaded-trick-overloading-lambdas-in-cpp17/
- http://mikejsavage.co.uk/cpp-tricks-type-id/
- https://andreasfertig.com/courses/programming-with-cpp11-to-cpp17/
- https://www.scs.stanford.edu/~dm/blog/param-pack.html
- https://www.modernescpp.com/index.php/smart-tricks-with-fold-expressions/
- https://andreasfertig.com/books/notebookcpp-tips-and-tricks-with-templates/
- https://abseil.io/tips/
- https://github.com/tip-of-the-week/cpp
- https://stackoverflow.com/questions/75538/hidden-features-of-c
- https://www.reddit.com/r/cpp_questions/comments/161wfp1/do_you_know_some_lesser_known_cc_tricks_or/
- https://learn.microsoft.com/en-us/shows/pure-virtual-cpp-2022/cute-cpp-tricks-part-2-of-n-more-code-you-should-learn-from-and-never-write
- https://prajwalshetty.com/ue5/Useful-Unreal-Links/
- https://www.codeproject.com/Tips/5249485/The-Most-Essential-Cplusplus-Advice
- https://jorenar.com/blog/less-known-c
- https://theorangeduck.com/page/delta-time-frame-behind
- https://www.reddit.com/r/unrealengine/s/ZvVB2DkX4c
- 

#### pitfall of `for (const pair<K, V>& kv : my_map)`

Here, `kv` is a copy instead of const reference since std::meow_map `value_type`
is `std::pair<const Key, T>`, notice **const Key**.

``` cpp {.numberLines}
// wrong
for (const std::pair<std::string, int>& kv : my_map)
    // ...
```

`pair<std::string, int>` is copy-constructed from `pair<const std::string, int>`
. Proper version:

``` cpp {.numberLines}
// correct
for (const std::pair<const std::string, int>& kv : my_map)
    // ...
```

Note, [AAA style (Almost Always Auto)](https://herbsutter.com/2013/08/12/gotw-94-solution-aaa-style-almost-always-auto/)
recommends to go with `const auto&` that also solves the problem
(sadly, with the loss of explicitly written types):

``` cpp {.numberLines}
// correct
for (const auto& kv : my_map)
    // ...
```

with C++17 structured binding, it's also:

``` cpp {.numberLines}
// correct
for (const auto& [key, value] : my_map)
    // ...
```

See [/u/STL](https://www.reddit.com/user/STL/) [comments](https://www.reddit.com/r/cpp/comments/1fhncm2/comment/lndnk8m/).
Note on /u/STL [meow](https://brevzin.github.io/c++/2023/03/14/prefer-views-meow/).

#### declare function with typedef/using

Surprisingly, you can declare a function with using declaration:

``` cpp {.numberLines}
using MyFunction = void (int);

// same as `void Foo(int);`
MyFunction Foo;

// actual definition
void Foo(int)
{
}
```

Notice, Foo is **not** a variable, but function declaration.
Running the code above with `clang -Xclang -ast-dump`, shows:

``` {.numberLines}
`-FunctionDecl 0xcc10e50 <line:4:1, col:12> col:12 Foo 'MyFunction':'void (int)'
  `-ParmVarDecl 0xcc10f10 <col:12> col:12 implicit 'int'
```

Same can be done to declare a method:

``` cpp {.numberLines}
struct MyClass
{
    using MyMethod = void (int, char);
    // member function declaration
    MyMethod Bar;
    // equivalent too:
    // void Bar(int);
};

// actual definition
void MyClass::Bar(int)
{
}
```

Mentioned at least [there](https://www.reddit.com/r/C_Programming/comments/2pkwvf/comment/cmxlx0e).
See also:

``` cpp {.numberLines}
typedef double MyFunction(int, double, float);
MyFunction foo, bar, baz; // functions declarations
```

#### protected/private virtual functions override

Access rights are resolved at compile-time, virtual function target - at
run-time. It's perfectly fine to move virtual-override to private section:

``` cpp {.numberLines}
class MyBase
{
public:
    virtual void Foo(int) {}
    // ...
};

class MyDerived : public MyBase
{
private:
    // note: Foo is private now
    virtual void Foo(int v) override {}
};

void Use(const MyBase& base)
{
    base.Foo(42); // calls override, if any
}

Use(MyDerived{});
```

It (a) clean-ups derived classes public API/interface (b) explicitly signals
that function is expected to be invoked from within framework/base class and 
(c) does not break Liskov substitution principle.

In heavy OOP frameworks that rely on inheritance (Unreal Engine, as an example),
it makes sense to make virtual-overrides protected instead of private so derived
class could invoke Super:: version in the implementation.


#### function try block

See [cppreference](https://en.cppreference.com/w/cpp/language/try#Function_try_block).
Specifically, to handle exceptions for constructor initializer:

``` cpp {.numberLines}
int Bar()
{
    throw 42;
}

struct MyFoo
{
    int data;
 
    MyFoo() try : data(Bar()) {}
    catch (...)
    {
        // handles the exception
    }
};
```

but also works just fine for regular functions to handle arguments construction
exceptions:

``` cpp {.numberLines}
void Foo(std::string) try
{
    // function body
}
catch (...)
{
    // exception handling for arguments
}
```

#### omiting `public` when deriving

Minor, still, see [cppreference, access-specifier](https://en.cppreference.com/w/cpp/language/derived_class):

``` cpp {.numberLines}
struct MyBase {};
struct MyDerived1 : MyBase {}; // same as : public  MyBase
class  MyDerived2 : MyBase {}; // same as : private MyBase
```

#### `(void)0` to force `;` for macros

To be consistent and force the user of the macro to put `;` at the line end:

``` cpp {.numberLines}
#define MY_FOO(MY_INPUT) \
    while (true) {       \
        MY_INPUT;        \
        break;           \
    } (void)0
    // ^^^^^^
MY_FOO(puts("X"));
MY_FOO(puts("Y"));
```

