# Exercise 2: Finding race conditions

```diff
 exercise2/
 ├── README.md               <-- you're here! -->
 ├── lib/
 │   ├── dune  
 │   ├── treiber_stack2.ml   <-- stack implementation with atomic size -->
 │   └── treiber_stack2.mli  <-- stack signature -->
 ├── solution/               <-- Solutions (same structure as test/) -->
 └── test/
     ├── dscheck_tests.ml     <-- Part 3: model checker -->
     ├── dune
     ├── qcheck_lin_tests.ml  <-- Part 2: sequential consistency tester -->   
     └── unit_tests.ml        <-- Part 1: unit test - a solution of exercise 1 -->
```

## Context

### Other implementations
Base implementation of Treiber's stack : [`exercises/base_implementation/treiber_stack.ml`](../base_implementation/treiber_stack.ml).

With a mutable size field: [`exercises/exercise1/lib/treiber_stack1.ml`](../exercise1/lib/treiber_stack1.ml).

### Removing the data races
In this exercise, we have modified the base implementation to remove the detected data races by making the size atomic. You can find this implementation in [`exercises/exercise2/lib/treiber_stack2.ml`](lib/treiber_stack2.ml).

## Objective

The objective of this exercise is to find and write a test that catches the existing bug in the implementation with the help of a linearizability checker (called [`qcheck-lin`](https://github.com/ocaml-multicore/multicoretests)) and then translate this test to a model checker (called [`dscheck`](https://github.com/ocaml-multicore/dscheck)) to obtain a trace of the bug.

## 1. (Required TSan) Checking the data race is gone

> **💡 Note**: Only if TSan works on your computer.

Let's check that the data race is gone (or seems to be, at least). First, make sure the test `test_push_pop` in `test/unit_tests.ml` matches the number of repeats and the set of `push` and `pop` calls that you had in the first exercise.

*Then run the test with TSan again. Does TSan report any data races?*

That does not mean there are no more data races, but that no data race occurred during this particular run of the test. However, if the test was consistently triggering the bug before, it is a good sign that this data race is gone.

For the rest of the exercise, we recommend switching back to the opam switch without TSan.
```shell
opam switch 5.4.0
eval $(opam env)
```

## 2. Finding a test that fails
There is still a bug in this implementation. To find it, we could study the code carefully or write an exhaustive test suite, but a more practical approach is to use `qcheck-lin` which tests for sequential consistency by generating many random tests to produce a failing test case for us.

`qcheck-lin` is based on QCheck, a property-based testing library in the style of QuickCheck from Haskell. You can find some explanation on how `qcheck-lin`  works at the end of this exercise (see the [About `qcheck-lin` section](#about-qcheck-lin)).


### Step 2.1: Find a failing test case with `qcheck-lin`
*Have a look at the file `test/qcheck_lin_tests.ml`. The `size` function is missing from the API description. Add it to the list of functions to test and run the test suite. You should see a failing test case.*

```shell
dune exec ./test/qcheck_lin_tests.exe
```

If the tests take too long to run (more than a minute), you can reduce the number of tests by changing the `~count` parameter in the `QCheck_runner.run_tests` function.

`qcheck-lin` is doing its best to shrink the test to a minimal failing test case, but because it is a non-deterministic bug it may fail to reduce it enough to be easy to understand. You can rerun it a few time until yoy get an example with *at most 6 or 7* operations on it.


This failing test will be described by a graph looking like:

```
                  |
                Push 0 : ()
                  |
      .-------------------------.
      |                         |
  Push 1 : ()                 Pop : Some 1
                              Pop : Some 0
```
This correspond to the following test:
- `[push 0]` is run first 
- then, two domains are spawned to run:
    - `[push 1]` on one domain
    - `[pop; pop]` on another domain

### Step 2.2 
*Analyse the failing test case. Why is it not what is expected?*

For example:
```
                  |
                Push 0 : ()
                  |
      .-------------------------.
      |                         |
  Push 1 : ()                 Pop : None
```
Is wrong because the `pop` can't return `None`. It should return `Some 1` or `Some 0` depending on the interleaving of the operations. 


### (Required TSan) Step 2.3: Translate the test case to a unit test

> **💡 Note**: Only if TSan works on your computer.

*Translate the failing test case to a unit test and run it with TSan. Is it a data race?*


## 3. Trace of the bug

The Treiber stack is a very simple implementation. Having a failing test may be enough to identify and understand the bug in the implementation. In other cases, a trace is most likely required to understand what is happening. For that, we can use a model checker called `dscheck`. 

`dscheck` is a model checker: it exhaustively go through every possible interleaving in between the atomic calls in the provided test and check that the properties given at the end of the test hold. If not, it returns a trace of the failing interleaving. 

See [About `dscheck`](#about-dscheck) for more.

> **💡 Note**: as a model checker, `dscheck` has an exponential complexity (even so it is quite optimized), so if too many atomic operations are performed in a test, it can take forever to run.


### Step 3.1: Translate the test case to a `dscheck` test
*Translate the failing case you found with `qcheck-lin` in `test/dscheck_test.ml.`*

You can use the test already written in `test/dscheck_test.ml` as a template. You also need to know what you are checking for. In the example [above](#step-22), you would check that the `pop` operations do not return `None` (i.e., that the stack is not empty).

To run the `dscheck` tests:

```shell
dune exec ./test/dscheck_tests.exe
```

### Step 3.2: Find the bug with `dscheck`
*Find the bug in the implementation by reading the trace of the failing test case.*

You can find some useful tips on how to read the trace at the end of this file [here](#reading-a-dscheck-trace).

If you have some time left, *you can try to implement a fix for it and check that all the tests are now passing.*


## About

### About `qcheck-lin`

[`qcheck-lin`](https://github.com/ocaml-multicore/multicoretests) provides an embedded combinator DSL to describe the signature of the library under test succinctly. From this description, it generates random sequences of commands, executes them in parallel, and checks whether the observed results are *linearizable*, that is, whether they can be explained by some sequential ordering of the same operations. If so, each operation appears to have taken effect atomically at some point between its invocation and its response.


`qcheck-lin` is not exhaustive, but it can find bugs that are hard to trigger with unit tests, and it is much faster than a model checker like `dscheck`.

For example, with the Treiber stack, it could generate a test case like this one:
- first, run sequentially: `[push 0]`
- then, run in parallel:
    - `[push 1]` on one domain
    - `[pop; pop]` on another domain

This would be described by a graph looking like:

```
                Push 0
                  |
      .-------------------------.
      |                         |
  Push 1                      Pop
                              Pop 
```
Then `qcheck-lin` would check that some sequential execution of these commands can produce the observed results. In this case, there are 3 possible interleavings:
- `push 0` -> `push 1` -> `pop` -> `pop` that would produce `Pop: Some 1` and `Pop: Some 0`
- `push 0` -> `pop` -> `push 1` -> `pop` that would produce `Pop: Some 0` and `Pop: Some 1`
- `push 0` -> `pop` -> `pop` -> `push 1` that would produce `Pop: Some 0` and `Pop: None`

If one of these matches the result observed while running the test in parallel, then the test passes. Otherwise, it fails: the implementation produced a result that no sequential execution could explain, which means there is a *race condition*.

> Go back to the [2. Finding a test that fails](#2-finding-a-test-that-fails) to resume the exercise.


### About `dscheck`

[`dscheck`](https://github.com/ocaml-multicore/dscheck) instruments the `Atomic` module to compute and explore all possible interleavings of the atomic operations performed in a test. If a test fails, it reports a trace of the first failing interleaving it finds. This trace can then be used to locate the bug in the implementation. Because it is exhaustive and nothing is actually run concurrently, `dscheck` is deterministic: if there is a bug reachable by the written test, it will always find it.

Contrary to `qcheck-lin`, the interleavings considered are not between function calls but between individual atomic operations. For example, a `push` is implemented as:
```
get stack
compare_and_swap stack
fetch_and_add size
```
and a `size` is implemented as:
```
get size
```

For a test that performs `push 0` on one domain (P0) and `size` on another (P1), `dscheck` will sequentially run all of the following interleavings and check the user-defined properties for each of them:
```
----------------------------------------
P0                      P1
----------------------------------------
Interleaving 1
----------------------------------------
get stack               
compare_and_swap stack
fetch_and_add size
                        get size
----------------------------------------
Interleaving 2
----------------------------------------
get stack               
compare_and_swap stack
                        get size
fetch_and_add size
----------------------------------------
Interleaving 3
----------------------------------------
get stack               
                        get size
compare_and_swap stack
fetch_and_add size     
----------------------------------------
Interleaving 4
----------------------------------------
                        get size
get stack               
compare_and_swap stack
fetch_and_add size     
----------------------------------------
```

> Go back to the [3. Trace of the bug](#3-trace-of-the-bug) to resume the exercise.

### Reading a `dscheck` trace
> **💡 Tips**: `dscheck` traces are not easy to read. Here are a few things to know:
> - Variables are named `a`, `b`, etc. instead of their actual names. You need to figure out which is which from the operations performed on them (e.g., `compare_and_swap` is used on the stack, `fetch_and_add` on the size).
> - The trace is divided into two columns (P0 and P1), one for each domain. The operations are listed in the order they were executed.
> - `Atomic.incr` and `Atomic.decr` appear as `fetch_and_add` in the trace.

Here is an example of a (non-buggy) trace, where P0 pushes three times and P1 pops once then calls `size`:

```
----------------------------------------
P0                      P1
----------------------------------------
start
get b
compare_and_swap b
fetch_and_add a
get b
compare_and_swap b
fetch_and_add a
get b
compare_and_swap b
fetch_and_add a
                        start
                        get b
                        compare_and_swap b
                        fetch_and_add a
                        get a
----------------------------------------
```

Here, `b` is the stack (used with `compare_and_swap`) and `a` is the size (used with `fetch_and_add` and `get`).

> Go back to the [step 3.2](#step-32-find-the-bug-with-dscheck) to resume the exercise.