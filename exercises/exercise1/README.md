# Exercise 1: Finding a data race

```diff
 exercise1/
 ├── README.md               <-- you're here! -->
 ├── lib/
 │   ├── dune  
 │   ├── treiber_stack1.ml   <-- stack implementation -->
 │   └── treiber_stack1.mli  <-- stack signature -->
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
| `dune exec ./path/to/test.exe`     | Run a specific test executable.              |
| `dune runtest -f`                  | Run all the tests in the current directory.  |

> **💡 Note**: `dune runtest` is shorter, however, this runs all the executables labelled as tests in the current directory. This is convenient when checking nothing has been broken in the whole project, but it is not ideal in a debugging phase, like for this tutorial.

## Context

### Base implementation
You can find a base implementation of Treiber's stack in `exercises/base_implementation/treiber_stack.ml`. It is a lock-free stack implementation that does not maintain the size of the stack.

### Adding size tracking
In this exercise, we have modified the base implementation to maintain the size of the stack. The modified implementation is in `exercises/exercise1/lib/treiber_stack1.ml`.

You can see how this implementation differs from the base one with a `diff` command:

```shell
diff -u base_implementation/treiber_stack.ml exercise1/lib/treiber_stack1.ml
```

**Design note**: we are trying to avoid using `List.length` because it is linear in the size of the stack, which would make the `size` function inefficient. Instead, we maintain a mutable `size` field that is updated on each push and pop operation.

## Objective

The objective of this exercise is to understand how to find what is wrong with the stack implementation.

The first step is being able to identify that the implementation is wrong. For that, we wrote a single unit test in `exercises/exercise1/test/unit_tests.ml`. In this exercise, we will modify it to consistently catch the bug.

### Step 0: Running the test
First, have a look at the test. You can run it using the following command:
```shell
dune exec ./test/unit_tests.exe
```

> **💡 Note**: Make sure you are in the `exercises/exercise1` directory.


## 1. Adding the size function to the test
This unit test is written for the Treiber stack implementation without a size.

### Step 1.1
Modify the test `test_push_pop` to also check that the size of the stack is correct after the push and pop operations.

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

### Step 2.2

Try to find a number of repetitions that makes the test fail consistently.

It is quite long, right? This is because the test is badly written: we spawn two domains at every repetition, but spawning a domain in OCaml is quite expensive! The next step should fix this issue.

### Step 2.3

Improve the test by adding more push and pop operations in each domain, instead of just one. A few of each should be enough. You may also have to adapt the properties that are checked at the end of the test.

At this point, you should be able to see the test failing consistently, without the test taking too long to run.

> **💡 Tip**: We don't need to consider the popped element, as we are assuming the original Treiber stack implementation is working. You can ignore the return value of a function with the following syntaxes:
> ```ocaml
> let _ = Stack.pop_opt stack in
> (* or *)
> ignore (Stack.pop_opt stack);
> ...
> ```

## 3. Identifying the bug

A nondeterministic bug in a concurrent program is often a sign of a race condition. There are two kinds of race conditions we are looking for today:
- data races
- race conditions between atomic operations (covered in exercises 2 and 3)

> **💡 Note**: If you have reached this point before my explanation about data races and race conditions, and you don't already know about them, no worries, you can still continue, all you really need to know is written below.

We will start with data races. The second and third exercises will cover the second kind of race conditions.

A *data race* is a particular race condition. The recipe for a data race is the following:

1. Several domains run in parallel
2. At least two domains access the same mutable value simultaneously
3. At least one of the accesses is a write
4. The value is not atomic

> **💡 Note**: Non-atomic mutable values in OCaml are:
> - reference cells (`ref`),
> - mutable fields in records (`{...; mutable field:...}`),
> - mutable arrays (`Array` and `Bigarray`).

To catch a data race, we use the same tool that other languages use: ThreadSanitizer (TSan). TSan instruments the compiler to detect data races during execution.

To run the test with TSan, you need to use the second switch where TSan is enabled. You can switch to it with the following command:

```shell
opam switch ocaml+tsan
eval $(opam env)
```

### Step 3.1
Run the test again. If the test is failing, you should see a (long) message from TSan giving the trace of the data races encountered during the execution.

### Step 3.2
You can now try to follow a trace to find the bug. Can you think of a fix for it? If you have some time left, you can try to implement it!