---
dimension: 16:9
---

<!-- slipshow serve -o presentation/presentation.html presentation/presentation.md -->

{#beginning}

<h1 style="text-align: center;">Parallelism without panic: </h1>
<h2 style="margin-top: -15px; text-align: center">A user’s guide to multicore safety in OCaml</h2>


## Setup 

The set up instructions are here: 
```shell
https://github.com/lyrm/bobkonf2026#setup
```

You also need to clone the following repository, which contains the exercises we will be working on during the tutorial: 

```shell
git clone git@github.com:lyrm/bobkonf2026.git
```

If you cloned it sooner this week, make sure to pull the latest changes!

{pause up}
## OCaml
- Functional-first but multi-paradigm (supports imperative and object-oriented styles)
- Static type system with Hindley–Milner type inference
- Advanced features: powerful module system, GADTs, polymorphic variants {pause}
- Since December 2022 (OCaml 5): Multicore support and effect handlers

{pause}
**Before OCaml 5**: most bugs are caught at compile time, 

**Since OCaml 5**: some bugs can only be caught at runtime (e.g. race conditions, etc.)

{pause}
- No way to check for it statically ?
- Otherwise, what tools to compensate for the lack of static guarantees ?

<!-- {pause}
**Small survey**: 
- Who knows OCaml?
- Who knows about multicore programming (in particular, lock-free data structures, data races, race conditions, etc..) -->

{pause up}
## Requirements 
{pause}
We are going to explore [*multicore programming*]{style="color:blue"} issues in [*OCaml*]{style="color:orange"} in 1h30 so ... {pause}

- being familial with [*OCaml*]{style="color:orange"} will help 
- as well as knowing a bit about [*multicore programming*]{style="color:blue"}

{pause}
But:
- Most concepts will be shortly explain as we go, 
- Most of the exercises don't require to write more than a few lines of code,
- And we will be here to help you if you get stuck!

{pause up}
## Contents

### Objective
 Learn how to find, reproduce, and fix concurrency bugs in OCaml using dedicated testing tools.

{pause}

### In practice

We add a `size` function to a lock-free Treiber stack and deliberately fall into every trap along the way.

{pause}

1. 🎓 The Treiber stack & a first buggy `size` function
2. 🕳️ **Exercise 1**: Fall into a data race, climb out with unit tests + TSan
3. 🎓 Data races & race conditions
4. 🕳️ **Exercise 2**: Fall into a race condition on atomics, climb out with qcheck-lin + dscheck
5. 🧰 **Bonus**: OxCaml, never fall again (statically prevent data races)


{pause up}

## Lock-free stack {#part1}

{include src=1-treiber.md}

{pause up-at-unpause=part2}
## Race conditions and data races {#part2}

{style="display: flex; gap: 1rem; position:relative"}
> {slip}
> > {include src=2-race-conditions.md}
> 
> {slip}
> > {include src=2-data-races.md}

{pause up-at-unpause=part2}

{pause up}
{include src=2-concl-ex1.md}

{pause up}
### Second pitfall: atomic size field

{.columns-2b #phases}
---

{include src=2-atomic-implem.md}


> > 
> {.block .box reveal #ex2}
> > 📝 Exercise 2: race conditions on atomic operations
> > - A new implementation with an atomic size field
> > - Check the previous bug is gone with TSan
> > - Find a test that fails with `qcheck-lin`
> > - Find a trace of the bug with a model checker (`dscheck`) 
>

---

{pause up}
{include src=2-concl-ex2.md}


{pause up-at-unpause=part3}
## Conclusion on multicore-safety in OCaml {#part3}
{include src=3-conclusion.md}

{pause up-at-unpause=part4}
## OxCaml {#part4}

