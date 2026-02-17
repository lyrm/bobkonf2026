---
dimension: 16:9
---

<!-- slipshow serve -o presentation/presentation.html presentation/presentation.md -->

{#beginning}

<h1 style="text-align: center;">Parallelism without panic: </h1>
<h2 style="margin-top: -15px; text-align: center">A user’s guide to multicore safety in OCaml</h2>

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
</table>

{pause up}
## What is this talk about?
OCaml: 
- Functional-first but multi-paradigm (supports imperative and object-oriented styles)
- Static type system with Hindley–Milner type inference
- Advanced features — powerful module system, GADTs, polymorphic variants {pause}
- Since December 2022 (OCaml 5): Multicore support and effect handlers

{pause}
Before OCaml 5: most bugs are caught at compile time, 
Since OCaml 5: some bugs can only be caught at runtime (e.g. race conditions, etc.)

{pause}
Small survey: Who knows OCaml?

{pause up}
## Requirements 
{pause}
- Ideally none, 
- Concretly, we are going to explore <span style="color:blue">*concurrency*</span> issues in <span style="color:orange">*OCaml*</span> in 1h30 so .. {pause}
    - being familial with OCaml will help 
    - know a bit about multicore programming 
- But:
    - Most concepts will be shortly explain as we go, 
    - Most of the exercises does not require to write more than a few lines of code,
    - And we will be here to help you if you get stuck!
{pause}    

## Contents
- 


## Part 1 {#part1}

{include src=part1.md}

{pause up-at-unpause=part2}

## Part 2 {#part2}


{pause}

## Conclusion

