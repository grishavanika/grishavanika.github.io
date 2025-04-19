---
title: Styles of Asynchronous API
include-before: |

    Showcase different variations of asynchronous API with an examples
    of using [libcurl](https://curl.se/libcurl/c/), specifically,
    doing 2 consecutive GET requests, sequentially and 2 GET requests -
    concurrently.

    NO threads and/or multithreading involved. Something is intentionally
    simpler, while still having as much details as possible.
---

--------------------------------------------------------------------------------

# intro

I want to have simple C-style API on top of [libcurl C API](https://curl.se/libcurl/c/)
and build a program that may look like this:

``` cpp {.numberLines}
std::string CURL_get(const std::string& url);

int main()
{
    const std::string v1 = CURL_get("localhost:5001/file1.txt");
    const std::string v2 = CURL_get("localhost:5001/file2.txt");
    return int(v.size() + v2.size()); // handle results
}
```

Just 2 requests + some data post-processing for the sake of argument.

Next, I'd like to have idiomatic C-style callbacks API to run requests
concurrently. The same task above is more involved now:

``` cpp {.numberLines}
using CURL_Async = void*;
CURL_Async CURL_async_create();
void CURL_async_destroy(CURL_Async curl_async);
void CURL_async_tick(CURL_Async curl_async);

void CURL_async_get(CURL_Async curl_async
    , void* user_data
    , const std::string& url
    , void (*callback)(void* user_data, std::string response));

int main()
{
    struct State
    {
        int count = 0;
        std::string v1;
        std::string v2;
    };

    CURL_Async curl_async = CURL_async_create();
    State state;
    CURL_async_get(curl_async, &state, "localhost:5001/file1.txt"
        , [](void* user_data, std::string response)
    {
        State& state = *static_cast<State*>(user_data);
        state.count += 1;
        state.v1 = std::move(response);
    });
    CURL_async_get(curl_async, &state, "localhost:5001/file2.txt"
        , [](void* user_data, std::string response)
    {
        State& state = *static_cast<State*>(user_data);
        state.count += 1;
        state.v2 = std::move(response);
    });
    while (state.count != 2)
    {
        CURL_async_tick(curl_async);
    }
    CURL_async_destroy(curl_async);
    return int(state.v1.size() + state.v2.size());
}
```

After this, lets build [tasks](#tasks), [std::future](#future),
[coroutines](#coroutines), [fibers](#fibers), [senders](#senders) and other
variations of asynchronous API on top of C-style callbacks.

But before that, lets wrap [libcurl C API](https://curl.se/libcurl/c/)
for our needs.

--------------------------------------------------------------------------------

# cmake with libcurl vcpkg setup

# libcurl, blocking API with easy interface
# libcurl, asynchronous API with multi interface

# blocking, synchronous (App_Blocking) {#sync}

## on error handling

### assume success always (tooling) {.unnumbered .unlisted}
### implicit, return empty string {.unnumbered .unlisted}
### status code, out parameter (std::filesystem-style) {.unnumbered .unlisted}
### optional {.unnumbered .unlisted}
### exceptions {.unnumbered .unlisted}
### result/variant-like {.unnumbered .unlisted}
### result/tuple-like {.unnumbered .unlisted}
### result/specialized {.unnumbered .unlisted}

# async polling, tasks  (App_Tasks)
# blocking std::future/promise
# async polling, std::future/promise
# async, callbacks (App_Callbacks)
# async, callbacks + polling (tasks, handle)
# async with statefull/implicit callback (state.on_X.subscribe/delegates)
# coroutines on top of callbacks (App_Coro)
# coroutines on top polling tasks
# fibers (WIN32) (App_Fibers)
# senders
# reactive streams

