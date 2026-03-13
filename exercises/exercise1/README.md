# Exercise 1: Finding a data race

```diff
 exercise1/
 ├── README.md               <-- you're here! -->
 ├── lib/
 │   ├── dune
 │   ├── treiber_stack1.ml   <-- stack implementation -->
 │   └── treiber_stack1.mli  <-- stack signature -->
 ├── solution/
 │   ├── dune
 │   └── unit_tests_sol.ml   <-- solution -->
 └── test/
     ├── dune
     └── unit_tests.ml       <-- a unit test -->
```

## Building the project and running the tests
Building the project and running the tests is done using `dune`, the OCaml build system.

From `exercises/exercise1`, you can use the following commands:

| Command                            | Description                                  |
|------------------------------------|----------------------------------------------|
| `dune build`                       | Compile the project and all the tests.       |
| `dune exec ./test/unit_tests.exe`  | Compile and run a specific test executable.              |
| `dune runtest -f`                  | Compile and run all the tests in the current directory.  |

> **💡 Note**: `dune runtest` is shorter, however, this runs all the executables labelled as tests in the current directory. This is convenient when checking nothing has been broken in the whole project, but it is not ideal in a debugging phase, like for this tutorial.

## Context

### Base implementation
You can find a base implementation of Treiber's stack in [`exercises/base_implementation/treiber_stack.ml`](../base_implementation/treiber_stack.ml). It is a lock-free stack implementation that does not maintain the size of the stack.

### Adding size tracking
In this exercise, we have modified the base implementation to maintain the size of the stack. The modified implementation is in [`exercises/exercise1/lib/treiber_stack1.ml`](../exercise1/lib/treiber_stack1.ml).

You can see how this implementation differs from the base one with a `diff` command:

```shell
diff -u base_implementation/treiber_stack.ml exercise1/lib/treiber_stack1.ml
```

**Design note**: we are trying to avoid using `List.length` because it is linear in the size of the stack, which would make the `size` function inefficient. Instead, we maintain a mutable `size` field that is updated on each push and pop operation.

## Objective

The objective of this exercise is to understand how to find what is wrong with the stack implementation.

## 1. Adding the size function to the test

> **💡 Note**: For the given command line to work, you need to be in `exercises/exercise1` directory.

In `test/unit_tests.ml` you will find an unfinished unit test. The purpose of this exercise is to complete the test and make it catch consistently the bug. 

To run the test:
```shell
dune exec ./test/unit_tests.exe
```
Currently the test always passes as it returns `true` (line 47).

*Modify it to check that the value returned by the newly added `Stack.size` function is valid.*  

> **💡 Tip**: You can use the function `drain_all` that is commented at the start of this test file.

```
            ┌───────────────────────┐
    ┌──────►│   Run the tests.      │
    │       │   Are they failing?   │
    │       └───────────┬───────────┘
    │          ┌────────┴────────┐
    │         Yes                No
    │          │                 │
    │          │        This is not because
    │     Lucky you!   the implementation is
    │     Try again.    correct, but because
    │          │          the bug is not
    │          │         deterministic.
    └──────────┘                 │
                                 ▼
                      Move to the next step
                    to improve the likelihood
                      of seeing the failure.
```

## 2. Improving the likelihood of seeing the failure
### Step 2.1

To increase the likelihood of triggering the bug, we need to repeat the test multiple times. For that, you can use the pre-defined `repeat : int -> (unit -> bool) -> bool` function in the `Utils` module to run the test multiple times.

*Try to find a number of repetitions that makes the test fail consistently.*

It is quite long, right? This is because the test is badly written: we spawn two domains at every repetition, but spawning a domain in OCaml is quite expensive! The next step should fix this issue.

### Step 2.2

*Improve the test by adding several `push` and `pop` operations in each domain, instead of just one.*

 A few of each should be enough. You may also have to adapt the properties that are checked at the end of the test.

At this point, you should be able to see the test failing consistently, without the test taking too long to run.

## 3. Identifying the bug

A nondeterministic bug in a concurrent program is often a sign of a race condition. There are two kinds of race conditions we are looking for today:
- data races
- race conditions between atomic operations (covered in exercise 2)

> **💡 Note**: If you have reached this point before the explanation about data races and race conditions, and you don't already know about them, no worries, you can still continue, all you really need to know is written at [at the end of this file](#about-data-races-in-ocaml-5s-memory-model).

### Catching the data races
To catch a data race, we use the same tool that other languages use: ThreadSanitizer ([TSan](https://ocaml.org/manual/5.3/tsan.html)). TSan instruments the compiler to detect data races during execution.

> **💡 IMPORTANT WARNING**: 
> Unfortunately, we could not make Tsan work on Codespaces as it requires to requires to lower the ASLR entropy of your machine.
>
> If you are working locally, on a Linux machine, you can run:
> ```bash
> sudo sysctl -w vm.mmap_rnd_bits=28
> ```
> 
> Otherwise, you will find one trace that TSan can return on [`solution/tsan_trace`](solution/tsan_trace). In this case, you can move to [Step 3.2](#step-32).
> 

To run the test with TSan, you need to use the second switch where TSan is enabled. You can switch to it with the following command:

```shell
opam switch ocaml+tsan
eval $(opam env)
```

### (Required TSan) Step 3.1
*Run the test with the compiler with TSan enabled.*

If the test is failing, you should see a (long) message from TSan giving the trace of the data races encountered during the execution.

### Step 3.2

> **💡 Note**: 
> 
> If you were not able to get a TSan trace, you can find one in [`solution/tsan_trace`](solution/tsan_trace).
> 

*Try to follow a trace to find the bug.*

*Can you think of a fix for it?*

If you have some time left, you can try to implement it!


## (Optional) Additional information
### About data races in OCaml 5's memory model
A *data race* occurs when:

1. Two or more domains run in parallel,
2. at least two access the same non-atomic mutable value,
3. and at least one of them writes to it.

> **💡 Note**: Non-atomic mutable values in OCaml include:
> - reference cells (`ref`),
> - mutable record fields (`{...; mutable field : ...}`),
> - arrays (`Array`).

**What happens when there is a data race?** Unlike C/C++ where data races are undefined behavior, OCaml's memory model guarantees that your program won't crash or corrupt memory. However, you may observe *non-sequentially-consistent* results: the outcome may not correspond to any interleaving of the operations from each domain.

In a data-race-free program, OCaml guarantees *sequential consistency*: every execution behaves as if the operations of all domains were interleaved in some order. This is known as the **DRF-SC** property (Data-Race-Free implies Sequential Consistency).

For more on OCaml's memory model:
- https://ocaml.org/manual/5.4/parallelism.html
- https://ocaml.org/manual/5.4/memorymodel.html

Go back to [Identifying the bug](#3-identifying-the-bug) to continue the tutorial.



### Reading TSan traces
Here is the structure of a tsan trace:

```html
==================
WARNING: ThreadSanitizer: data race (pid=1305739) <!-- first data race -->
  Write .... <!-- what is the first side of the trace: a Write or a Read operation (at least one of the side is a Write) -->
    #0 <!-- Where the first side of the data race happens -->
    # <!-- rest of the trace -->

  Previous write of .... <!-- what is the second side of the trace (Read or Write) -->
    #0 <!-- Where the second side of the data race happens -->
    # <!-- rest of the trace -->

  Mutex M0 (0x72b4000001b0) created at: <!-- We don't care about the paragraph -->

  Mutex M1 (0x72b4000002c0) created at: <!-- We don't care about the paragraph -->

  Thread T8 (tid=1305761, running) created by main thread at: <!-- We don't care about the paragraph -->


  Thread T6 (tid=1305759, running) created by main thread at: <!-- We don't care about the paragraph -->

SUMMARY: <!-- a nice summary of what happen -->
==================
==================
<!-- another data race -->
```