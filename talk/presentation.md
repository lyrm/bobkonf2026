---
dimension: 16:9
---

<!-- slipshow serve -o presentation/presentation.html presentation/presentation.md -->

{#beginning}

<h1 style="text-align: center;">Parallelism without panic: </h1>
<h2 style="margin-top: -15px; text-align: center">A user’s guide to multicore safety in OCaml</h2>


TODO: set up and clone. 

<!-- 

{pause up}

## Set up 

<table border="0">
<tr><td>

### Already have OCaml set up?
Create 2 switches with the required packages:
```shell
opam switch create 5.4.0
eval $(opam env --switch 5.4.0)
opam install -y dscheck qcheck-stm
```

```shell
opam switch create tsan ocaml-option-tsan
eval $(opam env --switch tsan)
opam install -y dscheck qcheck-stm
```

To switch from on the another: 
```shell
opam switch [switch-name]
eval $(opam env --switch [switch-name])
```
</td>
<td>

{pause}

### OxCaml (optional)

Optionaly, if you are interested in OxCaml, you can also create a switch with OxCaml (but it's not required for the tutorial):
```shell
opam switch create 5.2.0+ox --repos ox=git+https://github.com/oxcaml/opam-repository.git,default
eval $(opam env --switch 5.2.0+ox)
```

To go to the OxCaml switch, you can use: 
```shell
opam switch 5.2.0+ox
eval $(opam env --switch 5.2.0+ox)
```

Some useful packages to install in the switch:
```shell
opam install -y ocamlformat merlin ocaml-lsp-server utop parallel core_unix
```

See [oxcaml.org](https://oxcaml.org/get-oxcaml/).
</td>
</tr>
</table> -->

{pause up}
## What is this talk about?
**OCaml:**
- Functional-first but multi-paradigm (supports imperative and object-oriented styles)
- Static type system with Hindley–Milner type inference
- Advanced features — powerful module system, GADTs, polymorphic variants {pause}
- Since December 2022 (OCaml 5): Multicore support and effect handlers

{pause}
**Before OCaml 5**: most bugs are caught at compile time, 

**Since OCaml 5**: some bugs can only be caught at runtime (e.g. race conditions, etc.)

{pause}
**Small survey**: Who knows OCaml?

{pause up}
## Requirements 
{pause}
- Ideally none, 
- Concretly, we are going to explore [*concurrency*]{style="color:blue"} issues in [*OCaml*]{style="color:orange"} in 1h30 so ... {pause}
    - being familial with [*OCaml*]{style="color:orange"} will help 
    - as well as knowing a bit about [*multicore programming*]{style="color:blue"}
- But:
    - Most concepts will be shortly explain as we go, 
    - Most of the exercises does not require to write more than a few lines of code,
    - And we will be here to help you if you get stuck!

{pause}
{.block title="If you are already familiar with OCaml or multicore programming"}
You can use the branch name "TODO" that follows the same path than the main one but with less hand-holding and more codes to write. 

{pause up}
## Contents

***Objective***: 
- find the bugs in a lockfree queue implementation in a *reliable way* thanks to [*adequate tools*]{style="color:blue"}.  

1. Quick look to the data structure. 
2. The issue with standard testing: non deterministic bugs
    1. 📝 Units testing (not reliable)
    2. 🎓 Race conditions, and data races in OCaml memory model
3. How to catch data races ?  
    1. 🎓 Adequate tools and process: [*Tsan and qcheck-lin*]{style="color:blue"}
    2. 📝 Let's find and fix the data races
4. What about race conditions on atomic operations ? 
    1. 🎓 Model checking with [*dscheck*]{style="color:blue"}
    2. 📝 Let's find and fix the bug 
    3. 📝 How to identify the dscheck tests to write with qcheck-lin 
5. Statically guaranteeing multicore safety with [*OxCaml*]{style="color:blue"}
    1. 🎓 OxCaml: using mode to prevent writing data races
    2. 📝 Quiz! 


{pause up}

## Lock-free single-consumer single-producer queue {#part1}

{include src=part1.md}

{pause up-at-unpause=part2}

## Part 2 {#part2}


{pause}

## Conclusion

