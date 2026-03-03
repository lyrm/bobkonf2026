# Exercise 2: Finding race conditions

```diff
 exercise2/
 ├── README.md               <-- you're here! -->
 ├── lib/
 │   ├── dune  
 │   ├── treiber_stack2.ml   <-- stack implementation with atomic size -->
 │   └── treiber_stack2.mli  <-- stack signature -->
 └── test/
     ├── dscheck_tests.ml     <-- Part 3: model checker -->
     ├── dune
     ├── qcheck_lin_tests.ml  <-- Part 2: test generator -->   
     └── unit_tests.ml        <-- Part 1: unit test - a solution of exercise 1 -->
```

## Context

### Other implementations
Base implementation of Treiber's stack : `exercises/base_implementation/treiber_stack.ml`.

With a mutable size field: `exercises/exercise1/lib/treiber_stack1.ml`.

### Removing the data races
In this exercise, we have modified the base implementation to remove the detected data races by making the size atomic. You can find this implementation in `exercises/exercise2/lib/treiber_stack2.ml`.

Here is the diff between the two implementations:

```diff
- type 'a t = { stack : 'a list Atomic.t; size : int ref }
+ type 'a t = { stack : 'a list Atomic.t; size : int Atomic.t }
---
- let create () = { stack = Atomic.make []; size = ref 0 }
+ let create () = { stack = Atomic.make []; size = Atomic.make 0 }
---
-         decr t.size;
+         Atomic.decr t.size;
---
-   if Atomic.compare_and_set t.stack before after then incr t.size
+   if Atomic.compare_and_set t.stack before after then Atomic.incr t.size
---
- let size t = !(t.size)
+ let size t = Atomic.get t.size
```

## Objective

The objective of this exercise is to find and write a test that catches the existing bug in the implementation with the help of a test generator (called `qcheck-lin`) and then translate this test to a model checker (called `dscheck`) to obtain a trace of the bug.

## 1. Checking the data race is gone

Let's check that the data race is gone (or seems to be, at least). First, make sure the test `test_push_pop` in `test/unit_tests.ml` matches the number of repeats and the set of `push` and `pop` calls that you had in the first exercise.

*Then run the test with TSan again. Does TSan report any data races?*

```shell
dune exec ./test/unit_tests.exe
```

That does not mean there are no more data races, but that no data race occurred during this particular run of the test. However, if the test was consistently triggering the bug before, it is a good sign that this data race is gone.

For the rest of the exercise, we recommend switching back to the opam switch without TSan, as it is much faster to run the tests.
```shell
opam switch ocaml
eval $(opam env)
```

## 2. Finding a test that fails
There is still a bug in this implementation. To find it, we could study the code carefully or write an exhaustive test suite, but a more practical approach is to use a test generator to produce a failing test case for us.

In our case, we are going to use a tool called `qcheck-lin`. This tool is based on QCheck, a property-based testing library in the style of QuickCheck from Haskell.

### About `qcheck-lin`

`qcheck-lin` provides an embedded combinator DSL to describe the signature of the library under test succinctly. From this description, it generates random sequences of commands, executes them in parallel, and checks whether the observed results can be explained by some sequential execution (this is called *linearizability*).

For example, with the Treiber stack, it could generate a test case like this one:
- first, run sequentially: `[push 0]`
- then, run in parallel:
    - `[push 1]` on one domain
    - `[pop; size]` on another domain

This would be described by a graph looking like:

```
                Push 0
                  |
      .-------------------------.
      |                         |
  Push 1                      Pop
                              Size 
```
Then `qcheck-lin` checks that some sequential execution of these commands can produce the observed results. In this case, there are 3 possible interleavings:
- `push 0` -> `push 1` -> `pop` -> `size` that would produce `Pop: 1` and `Size: 1`
- `push 0` -> `pop` -> `push 1` -> `size` that would produce `Pop: 0` and `Size: 1`
- `push 0` -> `pop` -> `size` -> `push 1` that would produce `Pop: 0` and `Size: 0`

If one of these matches the result observed while running the test in parallel, then the test passes. Otherwise, it fails: the implementation produced a result that no sequential execution could explain, which means there is a *race condition*.


### Exercise: Find a failing test case with `qcheck-lin`
*Have a look at the file `test/qcheck_lin_tests.ml`. The `size` function is missing from the API description. Add it to the list of functions to test and run the test suite. You should see a failing test case.*

```shell
dune exec ./test/qcheck_lin_tests.exe
```

If the tests take too long to run (more than one minute), you can reduce the number of tests by changing the `~count` parameter in the `QCheck_runner.run_tests` function.

### Exercise: Translate the test case to a unit test
*Translate the failing test case to a unit test and run it with TSan. Is it a data race?*

In the case of the Treiber stack, having a failing test may be enough to find the bug in the implementation. In other cases, you might want a trace of where the bug happens. For that, we can use a model checker called `dscheck`: this is part 3 of this exercise.

## 3. `dscheck` test to find a trace of the bug


### About `dscheck`

`dscheck` instruments the `Atomic` module to compute and explore all possible interleavings of the atomic operations performed in a test. If a test fails, it reports a trace of the first failing interleaving it finds. This trace can then be used to locate the bug in the implementation. Because it is exhaustive and nothing is actually run concurrently, `dscheck` is deterministic: if there is a bug reachable by the written test, it will always find it.

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



> **💡 Note**: `dscheck` is a model checker: its complexity is exponential, so if too many atomic operations are performed in a test, it can take forever to run.


### Exercise: Translate the test case to a `dscheck` test
In the `dscheck_tests.ml` file, you will find a simple test for `push` and `pop` alone. You can use it as a template to translate the failing test from the previous section into a `dscheck` test.

To run the `dscheck` tests:

```shell
dune exec ./test/dscheck_tests.exe
```

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