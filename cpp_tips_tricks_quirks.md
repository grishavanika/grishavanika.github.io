---
title: C++ tips, tricks and quirks.
---

To generate this .html out of [cpp_tips_tricks_quirks.md](https://raw.githubusercontent.com/grishavanika/grishavanika.github.io/refs/heads/master/cpp_tips_tricks_quirks.md):

```
pandoc -s --toc --toc-depth=4
  --number-sections
  --highlight=kate
  -f markdown -t html
  cpp_tips_tricks_quirks.md
  -o cpp_tips_tricks_quirks.html
```

Inspired by [Lesser known tricks, quirks and features of C](https://jorenar.com/blog/less-known-c).

-----------------------------------------------------------

[TODO]{.mark}

- cout and stdout synchronization
- initializer list crap (no move only)
- std::function crap (no move only)
- non-trivial types in union
- +\[]()
- no capture needed for globals/const for lambda
- operator-> and non pointer return type recursion
- operator Type for perfect forward construction
- overload struct for variant visit (inherit from lambda)
- map and modifying keys ub
- picewise construct
- map[x]
- emplace back with placement new pre c++11
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
- swap idiom (unqualified call to swap in generic context)
- https://en.wikipedia.org/wiki/Barton%E2%80%93Nackman_trick
- https://en.wikipedia.org/wiki/Category:C%2B%2B
- http://www.gotw.ca/gotw/076.htm
- (go thru idioms, shwartz counter, https://en.m.wikibooks.org/wiki/More_C++_Idioms)
- (go thru shortcuts, like immediately invoked lambda)
- see also https://github.com/shafik/cpp_blogs quiz questions
- (and https://cppquiz.org/)
- relocatable and faster then stl container implementations
- https://www.foonathan.net/2016/05/final/
- https://www.foonathan.net/2020/10/tricks-default-template-argument/
- https://www.foonathan.net/2020/10/iife-metaprogramming/#content
- `static_cast<decltype(args)>(args)...` - https://www.foonathan.net/2020/09/move-forward/#content
- Howard Hinnant special member function diagram - https://www.foonathan.net/2019/02/special-member-functions/#content
- modern C++ + value semantics = love

-----------------------------------------------------------

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

#### call a method of a template base class

See also [Accessing template base class members in C++](https://yunmingzhang.wordpress.com/2019/01/26/accessing-template-base-class-members-in-c/).

Given standard code like this:

``` cpp {.numberLines}
struct MyBase { void Foo(); };
struct MyDerived : MyBase
{
    void Bar() { Foo(); }
};
```

we can call `Base::Foo()` with no issues. However, in case when we use templates,
Foo() can't be found. The trick is to use `this->Foo()`. Or `MyBase<U>::Foo()`:

``` cpp {.numberLines}
template<typename T>
struct MyBase { void Foo(); };
template<typename U>
struct MyDerived : MyBase<U>
{
    void Bar() { this->Foo(); }
};
```

`this->Foo()` becomes [type-dependent expression](https://en.cppreference.com/w/cpp/language/dependent_name).

#### `= default` on implementation

You can default special member functions in the .cpp/out of line definition:

``` cpp {.numberLines}
struct MyClass
{
    MyClass();
};
// myclass.cpp, for instance:
MyClass::MyClass() = default;
```

Note, this is almost the same as = default in-place, but makes constructor
user-defined. Sometimes it's not a desired side effect. However, it's nice
in case you want to change the body of constructor later or put breakpoint
(since you don't need to change header and recompile dependencies, only .cpp file).

Another use-case is to move destructor to .cpp file so you don't delete
incomplete types:

``` cpp {.numberLines}
struct MyInterface; // forward-declare
struct MyClass
{
    std::unique_ptr<MyInterface> my_ptr;
    ~MyClass();
};
// myclass.cpp
#include "MyInterface.h" // include only now
MyClass::~MyClass() = default; // generate a call to my_ptr.~unique_ptr()
```

#### `= delete` for free functions

You can delete unneeded function overload anywhere:

``` cpp {.numberLines}
void MyHandle(char) = delete;
void MyHandle(int);
```

`MyHandle('x')` does not compile now.


#### `#line` and file renaming

See [cppreference](https://en.cppreference.com/w/c/preprocessor/line):

``` cpp {.numberLines}
// main.cpp
#include <assert.h>
int main()
{
#line 777 "any_filename.x"
    assert(false);
}
```

wich outputs:

> output.s: any_filename.x:777: int main(): Assertion `false` failed.

Note: this could break .pdb(s).  
Bonus: what happens if you do `#line 4294967295`?

#### Meyers cons_cast

To not repeat code inside const and non-const function, [see SO](https://stackoverflow.com/a/123995):

``` cpp {.numberLines}
struct MyArray
{
    char data[4]{};

    const char& get(unsigned i) const
    {
        assert(i < 4);
        return data[i];
    }
    char& get(unsigned i)
    {
        return const_cast<char&>(static_cast<const MyArray&>(*this).get(i));
    }
};
```

Note: mutable `get()` is implemented in terms of const version, not the other way
around (which would be UB).

Kind-a outdated with [C++23’s Deducing this](https://devblogs.microsoft.com/cppblog/cpp23-deducing-this/)
or is it? (template, compile time, .h vs .cpp).

#### missing `std::` and why it still compiles (ADL)

Notice, that code below will compile (most of the time):

``` cpp {.numberLines}
std::vector<int> vs{6, 5, 4, 3, 2, 1};
sort(vs.begin(), vs.end()); // note: missing std:: when calling sort()
```

Since std::vector iterator lives in namespace `std::` (\*), ADL will be performed
to find std::sort and use it. ADL = [Argument-dependent lookup (ADL),
also known as Koenig lookup](https://en.cppreference.com/w/cpp/language/adl).

(\*) Note, iterator could be just raw pointer (`int*`) and it's implementation
defined (?) where or not iterator is inside std. Meaning the code above
is not portable (across different implementations of STL).

#### why STL is using `::std::move` everywhere?

Take a look at [MSVC's implementation of the C++ Standard Library](https://github.com/microsoft/STL/blob/faccf0084ed9b8b58df103358174537233b178c7/stl/inc/algorithm#L452-L453):

``` cpp {.numberLines startFrom="452"}
_STD _Seek_wrapped(_First, _STD move(_UResult.in));
return {_STD move(_First), _STD move(_UResult.fun)};
```

\_STD is `#define _STD ::std::`. Why?  

So `::std::move` is used to **disable** ADL and make sure
implementation of `move` from namespace `std` is choosen.
Who knows what user-defined custom type could bring into the table?

#### `std::shared_ptr` aliasing constructor

See [aliasing constructor](https://en.cppreference.com/w/cpp/memory/shared_ptr/shared_ptr):

``` cpp {.numberLines}
struct MyType
{
    int data;
};

std::shared_ptr<MyType> v1 = std::make_shared<MyType>();
std::shared_ptr<int> v2{v1, &v1->data};
```

v2 and v1 now share the same control block.
You can also put a pointer to unrelative data (is there real-life use-case?).

#### `dynamic_cast<void*>` to get most-derived object

From anywhere in the hierarhy of polimorphic type, you can restore a pointer
to most-derived instance (i.e., the one created by `new` initially):

``` cpp {.numberLines}
struct MyBase { virtual ~MyBase() = default; };
struct MyDerived : MyBase {};

MyDerived* original_ptr = new MyDerived{};

MyBase* base_ptr = original_ptr;
void* void_ptr = dynamic_cast<void*>(base_ptr);

assert(void_ptr == original_ptr);
```

See [cppreference](https://en.cppreference.com/w/cpp/language/dynamic_cast).
Most-likely useful to interop with C library/external code.

#### `std::shared_ptr<base>` with no virtual destructor

Usually, if you delete pointer-to-base, destructor needs to be declared virtual
so proper destructor is invoked. Hovewer, for std::shared_ptr this is not required:

``` cpp {.numberLines}
struct MyBase { ~MyBase(); }; // no virtual!
struct MyDerived : MyBase
{
    ~MyDerived() { std::puts("~MyDerived()"); }
};

{
    std::shared_ptr<MyBase> ptr = std::make_shared<MyDerived>();    
} // invokes ~MyDerived()
```

`std::shared_ptr<MyBase>` holds `MyBase*` pointer, but has [type-erased](https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Type_Erasure)
destroy function that remembers the actual type it was created with.

See also [GotW #5, Overriding Virtual Functions](http://www.gotw.ca/gotw/005.htm):

> Make base class destructors virtual

#### stateful metaprogramming

This [works](https://b.atch.se/posts/constexpr-counter/) and a and b
have different values:

``` cpp {.numberLines}
int main () {
  constexpr int a = f();
  constexpr int b = f();

  static_assert(a != b);
}
```

See, for instance, [Revisiting Stateful Metaprogramming in C++20](https://mc-deltat.github.io/articles/stateful-metaprogramming-cpp20):

 * [constant-expression counter](https://b.atch.se/posts/constexpr-counter/)
 * [compile-time list](https://b.atch.se/posts/constexpr-meta-container/)
 * [nonconstant constant expressions](https://b.atch.se/posts/non-constant-constant-expressions/)
 * [stateful metaprogramming via friend injection](https://www.open-std.org/jtc1/sc22/wg21/docs/cwg%5Factive.html#2118)
 * [hack C++ with templates and friends](https://www.worldcadaccess.com/blog/2020/05/how-to-hack-c-with-templates-and-friends.html)

#### access private members

See [this](https://github.com/martong/access_private) for more details and explanations.
Similar to stateful metaprogramming.

Example [from C++20 version](https://github.com/schaumb/access_private_20):

``` cpp {.numberLines}
class A {
  int m_i = 3;
  int m_f(int p) { return 14 * p; }
};

template struct access_private::access<&A::m_i>;

void foo() {
  A a;
  auto &i = access_private::accessor<"m_i">(a);
  assert(i == 3);
}
```

#### extern templates

See, [this](https://isocpp.org/wiki/faq/cpp11-language-templates#extern-templates) or [cppreference](https://en.cppreference.com/w/cpp/language/class_template).

Allows to declare some set of template instantiations and actually intantiate
them in another place. Usually, you extern template in the header and instantiate
in **your own**/library .cpp file:

``` cpp {.numberLines}
// myvector.h
template<typename T>
class MyVector { /**/ };

// declare frequently used instantiations
extern template class MyVector<int>;
extern template class MyVector<float>;
extern template class MyVector<char>;

// myvector.cpp
#include "myvector.h"

// instantiate frequent cases **once**;
// client needs to link with myvector.o
template class MyVector<int>;
template class MyVector<float>;
template class MyVector<char>;
```

C++ had also never implemeted C++98 [export keyword](https://en.cppreference.com/w/cpp/keyword/export)
(C++98, nothing to do with [modules](https://en.cppreference.com/w/cpp/language/modules)).

#### templates in .cpp file

It's usually stated that templates could only be defined in header file.
However, you just need to define them anywhere so definition is visible at the
point of use/instantiation.

For intance, this works just fine:

``` cpp {.numberLines}
// myclass.h
class MyClass
{
public:
    int Foo();

private:
    template<typename T>
    int Bar();
};

// myclass.cpp
// template class, defined in this .cpp file
template<typename U>
struct MyHelper {};

template<typename T>
int MyClass::Bar()
{
    // definition of member-function-template Bar();
    // also, the use of MyHelper template above,
    // visible only to this transtlation unit
    return sizeof(MyHelper<T>{});
}

int MyClass::Foo()
{
    // use of function template
    return Bar<char>();
}
```

See also [extern templates](#extern-templates).

#### double-template syntax

If you have template class that has template member function
and you want to define such function out-of-class, you need:

``` cpp {.numberLines}
template<typename T1, typename T2>
class MyClass
{
    template<typename U>
    void Foo(U v);
};

template<typename T1, typename T2>  // for MyClass
template<typename U>                // for Foo
void MyClass<T1, T2>::Foo(U v) {}
```

#### when type T is bitcopyable?

When implementors do use memcopy/memmove to construct/assign range of values
for some user-defined type T? Use `std::is_trivially_*` [type traits](https://en.cppreference.com/w/cpp/meta)
to query the property:

``` cpp {.numberLines}
struct MyType
{
    int data = -1;
    char str[4]{};
};

int main()
{
    MyType v1{42};
    MyType v2{66};

    static_assert(std::is_trivially_copy_assignable<MyType>{});
    std::memcpy(&v1, &v2, sizeof(v1)); // fine
    assert(v1.data == 66);
}
```

Overall, see also [std::uninitialized_*](https://en.cppreference.com/w/cpp/memory/uninitialized_copy)
memory management and [std::copy algorithm](https://en.cppreference.com/w/cpp/algorithm/copy)
and/or analogs that are already optimized for trivial/pod types
by your standard library implementation for you.

#### pseudo destructors (~int)

In generic context, it's possible to invoke the destructor of int:

``` cpp {.numberLines}
using MyInt = int;
MyInt v = 86;
v.~MyInt();
```

which is no-op. See [destructor](https://en.cppreference.com/w/cpp/language/destructor#Notes)
and [built-in member access operators](https://en.cppreference.com/w/cpp/language/operator_member_access#Built-in_member_access_operators).
Exists so you don't need to special-case destructor call in generic/template code.

#### manually invoke constructor

In the same way you can call destructor manually, you can call constructor:

``` cpp {.numberLines}
alignas(T) unsigned char buffer[sizeof(T)];
T* ptr = new(static_cast<void*>(buffer)) T; // call constructor
ptr->~T();                                  // call destructor
```

which is [placement new](https://en.cppreference.com/w/cpp/lanzguage/new#Placement_new).

Note on the use of `static_cast<void*>` - while not needed in this example, it's
needed to be done in generic context to avoid invoking overloaded version of new,
if any.

#### injected-class-name

See [cppreference](https://en.cppreference.com/w/cpp/language/injected-class-name).
In short, every class has its own name inside the class itself. Which happens to
apply recursively. This leads to surprising syntax noone uses:

``` cpp {.numberLines}
struct MyClass
{
    int data = -1;
    void Foo();
};

int main()
{
    MyClass m;
    // access m.data
    m.MyClass::data = 4;
    assert(m.data == 4);
    // now with recursion
    m.MyClass::MyClass::MyClass::data = 7;
    assert(m.data == 7);
    // call a member function
    MyClass* ptr = &m;
    ptr->MyClass::Foo();
}
```

For templates, this allows to reference class type without specifying
template arguments.

``` cpp {.numberLines}
template<typename T, typename A>
struct MyVector
{
    // same as Self = MyVector<T, A>
    using Self = MyVector;
};
```

#### invoke base virtual function directly

Given an instance of derived class, one can skip invoking its own function
override and call parent function directly (see [injected-class-name](#injected-class-name)):

``` cpp {.numberLines}
struct MyBase
{
    virtual void Foo()
    { std::puts("MyBase"); }
};

struct MyDerived : MyBase
{
    virtual void Foo() override
    { std::puts("MyDerived"); }
};

int main()
{
    MyDerived derived;
    derived.MyBase::Foo();
    MyDerived* ptr = &derived;
    ptr->MyBase::Foo();
}
```

This will print `MyBase` 2 times since we explicitly call MyBase::Foo().

#### perfect construct with factory function

See `class rvalue` trick discussed [there](https://akrzemi1.wordpress.com/2018/05/16/rvalues-redefined/);
see same trick discussed in [guaranteed copy elision in C++17](https://groups.google.com/a/isocpp.org/g/std-proposals/c/hQ654zTNyiM).

In short, we can return non-copyable/non-movable type from a function:

``` cpp {.numberLines}
struct Widget
{
    explicit Widget(int) {}
    Widget(const Widget&) = delete;
    Widget& operator=(const Widget&) = delete;
    Widget(Widget&&) = delete;
    Widget& operator=(Widget&&) = delete;
};

Widget MakeWidget()
{
    return Widget{68}; // works
}

int main()
{
    Widget w = MakeWidget(); // works
}
```

However, how to construct, let say `std::optional<Widget>`? That does not work:

``` cpp {.numberLines}
int main()
{
    std::optional<Widget> o1{MakeWidget()}; // does not compile
    std::optional<Widget> o2;
    o2.emplace(MakeWidget()); // does not compile
}
```

The trick is to use any type that has [implicit conversion operator](https://en.cppreference.com/w/cpp/language/cast_operator):

``` cpp {.numberLines}
struct WidgetFactory
{
    operator Widget()
    {
        return MakeWidget();
    }
};

int main()
{
    std::optional<Widget> o;
    o.emplace(WidgetFactory{}); // works
}
```

#### disable template argument deduction

See, for instance, [What's the deal with std::type_identity?](https://devblogs.microsoft.com/oldnewthing/20240607-00/?p=109865)
or [dont_deduce\<T\>](https://artificial-mind.net/blog/2020/09/26/dont-deduce).
In short, this will not compile:

``` cpp {.numberLines}
template<typename T>
void Process(std::function<void (T)> f, T v)
{
    f(v);
}

int main()
{
    Process([](int) {}, 64);
}
```

We try to pass a lambda that has unique type X which has nothing to do with
`std::function<void (T)>`. Compiler does not know how to deduce T from X.

Here, we want to ask compiler to not deduce anything for parameter `f`:

``` cpp {.numberLines}
template<typename T>
void Process(std::type_identity_t<std::function<void (T)>> f, T v)
{
    f(v);
}

int main()
{
    Process([](int){}, 64);
}
```

T is deduced from 2nd argument, std::function is constructed from a given lamda
as it is.

#### priority_tag for tag dispatch

From [priority_tag for ad-hoc tag dispatch](https://quuxplusone.github.io/blog/2021/07/09/priority-tag/)
and [CppCon 2017: Arthur O'Dwyer "A Soupcon of SFINAE"](https://youtu.be/ybaE9qlhHvw?t=56m36s).

Here, we convert x to string trying first `x.stringify()` if that exists,
otherwise `std::to_string(x)` if that works and finally fallback to ostringstream
as a final resort:

``` cpp {.numberLines}
#include <string>
#include <sstream>

template<unsigned I> struct priority_tag : priority_tag<I - 1> {};
template<> struct priority_tag<0> {};

template<typename T>
auto stringify_impl(const T& x, priority_tag<2>)
    -> decltype(x.stringify())
{
    return x.stringify();
}

template<typename T>
auto stringify_impl(const T& x, priority_tag<1>)
    -> decltype(std::to_string(x))
{
    return std::to_string(x);
}

template<typename T>
auto stringify_impl(const T& x, priority_tag<0>)
    -> decltype(std::move(std::declval<std::ostream&>() << x).str())
{
    std::ostringstream s;
    s << x;
    return std::move(s).str();
}

template<typename T>
auto stringify(const T& x)
{
    return stringify_impl(x, priority_tag<2>());
}
```

#### new auto(10)

You can leave type dedcution to the compiler when using new:

``` cpp {.numberLines}
auto ptr1 = new auto(10); // works -> int*
int* ptr2 = new auto(10); // works
```

From [cppreference](https://en.cppreference.com/w/cpp/language/new):

``` cpp {.numberLines}
double* p = new double[]{1, 2, 3};  // creates an array of type double[3]
auto p = new auto('c');             // creates a single object of type char. p is a char*
auto q = new std::integral auto(1); // OK: q is an int*
auto r = new std::pair(1, true);    // OK: r is a std::pair<int, bool>*
```

#### `std::forward` use in std::function-like case

Most of the times, we say that std::forward should be used in the context
of forwarding references that, _usually_, look like this:

``` cpp {.numberLines}
template<typename T>
void Process(T&& v)
{
    Handle(std::forward<T>(v));
}
```

v is [forwarding reference](https://en.cppreference.com/w/cpp/language/reference#Forwarding_references)
specifically because T&& is used and T **is** template parameter of Process
function template.

However, classic example would be std::function call operator() implementation:

``` cpp {.numberLines}
template<typename Ret, typename... Types>
class function<Ret (Types...)>
{
    Ret operator()(Types... Args) const
    {
        return Do_call(std::forward<Types>(Args)...);
    }
};

// usage
function<void (int&&, char)> f; // (1)
f(10, 'x');                     // (2)
```

where user specifies `Types` at (1) that has nothing to
do with `operator()` call at (2) which is not even a function template now.

If you run [reference collapsing](https://en.cppreference.com/w/cpp/language/reference)
rules over possible `Types` and `Args`, `std::forward` is just right.

#### virtual functions default arguments

See [GotW #5, Overriding Virtual Functions](http://www.gotw.ca/gotw/005.htm):

> Never change the default parameters of overridden inherited functions

Going more strict: don't have virtual functions with default arguments.

``` cpp {.numberLines}
struct MyBase
{
    virtual void Foo(int v = 34);
};
struct MyDerived : MyBase
{
    virtual void Foo(int v = 43);
};
MyBase* ptr = new MyDerived;
ptr->Foo(); // calls MyDerived::Foo, but with v = 34 from MyBase
```

default arguments are resolved at compile time, override function target - at
run-time; may lead to confusion.

#### virtual functions overloads

See [GotW #5, Overriding Virtual Functions](http://www.gotw.ca/gotw/005.htm):

> When providing a function with the same name as an inherited function,
> be sure to bring the inherited functions into scope with a "using"
> declaration if you don't want to hide them

Going more strict: avoid providing overloads to virtual functions.  
For modern C++: use [override specifier](https://en.cppreference.com/w/cpp/language/override).

``` cpp {.numberLines}
struct MyBase
{
    virtual int Foo(char v) { return 1; }
};
struct MyDerived : MyBase
{
    virtual int Foo(int v) { return 2; }
};

int main()
{
    MyDerived derived;
    return derived.Foo('x');
}
```

main is going to return 2 since `MyDerived::Foo(int)` is used.
To use `MyBase::Foo(char)`:

``` cpp {.numberLines}
struct MyDerived : MyBase
{
    using MyBase::Foo; // add char overload
    virtual int Foo(int v) { return 2; }
};
```

Note: bringing base class method with using declation is, potentially,
a breaking change (see above, `derived.Foo('x')` now returns 1 instead of 2).

#### change base class member access rights

See [Using-declaration](https://en.cppreference.com/w/cpp/language/using_declaration).
You can make protected member to be public in derived class:

``` cpp {.numberLines}
struct MyBase
{
protected:
    int data = -1;
};
struct MyDerived : MyBase
{
public:
    using MyBase::data; // make data public now
};
```

#### use default constructor for state reset

It's observed that, often, class API has .Reset() function (even more often
when two phase initialization is used):

``` cpp {.numberLines}
struct MyClass
{
    int data = -1;
    // ...
    void Reset() { data = -1; }
};
```

If your API is anything close to modern C++ and supports [value semantics](https://youtu.be/G9MxNwUoSt0?si=qbFFjdXYKT58ZThN),
just have move assignment implemented with default constructor, which leads to:

``` cpp {.numberLines}
MyClass instance;
// ...
instance = MyClass{}; // same as .Reset()
```

See also "default constructor is a must for modern C++"

#### default constructor is a must for modern C++

What happens with the object after the move? The known answer for C++ library
types is that it's in ["valid but unspecified state"](https://en.cppreference.com/w/cpp/utility/move).
Note, that for most cases in practice, the object is in empty/null state
(see [Sean Parent comments](https://gist.github.com/sean-parent/fed31bee69bc41d888f84f25743da9f1))
or, to say it another way - you should put the object into empty state and be nice.

Why it's in "empty" state? Simply because destructor still runs after the move and
we need to know whether or not it's needed to free resources **most of the times**:

``` cpp {.numberLines}
struct MyFile
{
    int handle = -1;
    // ...
    ~MyFile()
    {
        if (handle >= 0)
        {
            ::close(handle);
            handle = -1;
        }
    }
    MyFile(MyFile&& rhs) noexcept
        : handle(rhs.handle)
    {
        rhs.handle = -1; // take ownership
    }
}
```

For a user or even class author, it's also often needed to check if the
object was not moved to ensure correct use:

``` cpp {.numberLines}
void MyFile::Read(...)
{
    assert(handle >= 0); // hidden/implicit is_valid check
}
```

Now, should the class expose `is_valid()` API? Maybe, maybe not; up to you.
More elegant solution that requires smaller amount of exposed APIs could be just
a pair of default construction and `operator==`:

``` cpp {.numberLines}
MyFile file = ...;
if (file == MyFile{})
    // empty, was moved from, can't invoke Read().
```

Leaving validity check alone, any time you support move, just expose such state
with default constructor. More often then not it makes life easier.
See also "state reset".

Relative: [Move Semantics and Default Constructors – Rule of Six?](https://www.foonathan.net/2016/08/move-default-ctor/).

#### default constructor must do no work

[TBD]{.mark}

This also applies to debug builds (see MSVC STL debug iterators machinery).

#### constructors should do no work

[TBD]{.mark}

#### `std::unique_ptr` with decltype lambda

Since C++20, with [Lambdas in unevaluated contexts](https://andreasfertig.blog/2022/08/cpp-insights-lambdas-in-unevaluated-contexts/),
you can have poor man's scope exit as a side effect:

``` cpp {.numberLines}
using on_exit = std::unique_ptr<const char,
    decltype([](const char* msg) { puts(msg); })>;

void Foo()
{
    on_exit msg("Foo");
} // prints Foo on scope exit
```

from [Creating a Sender/Receiver HTTP Server for Asynchronous Operations in C++](https://youtu.be/O2G3bwNP5p4?si=_2yfyq9BEoxF3etB).

#### `auto` vs `auto*` for pointers

Since auto type deduction comes from [template argument deduction](https://en.cppreference.com/w/cpp/language/template_argument_deduction#Other_contexts),
it's fine to have `auto*` in the same way it's fine to have `T*` as a template
parameter:

``` cpp {.numberLines}
auto  p1 = new int;        // p1 = int*
auto* p2 = new int;        // p2 = int*
const auto  p3 = new int;  // p3 = int* const
const auto* p4 = new int;  // p4 = const int*
```

Still, note the difference for p3 vs p4 - const pointer to int vs just pointer 
to const int!

#### std::transform and LIFT (passing overload set)

See [Passing overload sets to functions](https://blog.tartanllama.xyz/passing-overload-sets/):

``` cpp {.numberLines}
#define FWD(...) \
    std::forward<decltype(__VA_ARGS__)>(__VA_ARGS__)

#define LIFT(X) [](auto &&... args) \
    noexcept(noexcept(X(FWD(args)...)))  \
    -> decltype(X(FWD(args)...)) \
{  \
    return X(FWD(args)...); \
}

// ...
std::transform(first, last, target, LIFT(foo));
```

#### `tolower` is not an addressible function

You can't take an adress of std:: function since function could be implemented
differently with different STL(s) and/or in the feature the function
may change, hence such code is not portable. From [A popular but wrong way to convert a string to uppercase or lowercase](https://devblogs.microsoft.com/oldnewthing/20241007-00/?p=110345):

> The standard imposes this limitation because the implementation
> may need to add default function parameters, template default parameters,
> or overloads in order to accomplish the various requirements of the standard.

So, strictly speaking, ignoring facts from the article, this is not portable C++:

``` cpp {.numberLines}
std::wstring name;
std::transform(name.begin(), name.end(), name.begin(),
    std::tolower);
```
