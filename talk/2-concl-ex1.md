### Solution of exercise 1: Data races  on `int ref`

<style>
.interleaving-ex1 {
  font-size: 0.85em;
}
.interleaving-ex1 table {
  border-collapse: collapse;
  width: 100%;
}
.interleaving-ex1 th, .interleaving-ex1 td {
  padding: 0.3em 0.6em;
  text-align: left;
  border-bottom: 1px solid #ddd;
}
.interleaving-ex1 th {
  font-weight: bold;
  border-bottom: 2px solid #888;
}
.interleaving-ex1 .bug {
  color: crimson;
  font-weight: bold;
}
</style>

`incr`/`decr` on `int ref` are **not atomic**: they expand to a read then a write.

```ocaml
let incr r = r := !r + 1
let decr r = r := !r - 1
```

{.block .interleaving-ex1}
> | Step | Domain 1 (`push 42`) | Domain 2 (`pop`) | `size` (ref) |
> |------|----------------------|------------------|--------------|
> | 1 | `read size` → 0 | | 0 |
> | 2 | | `read size` → 0 | 0 |
> | 3 | `write size` ← 0 + 1 | | 1 |
> | 4 | | `write size` ← 0 - 1 | [**-1**]{.bug} |

{pause}

{.block .box}
> **Data race (lost update):** both domains read `size = 0` before either writes. Domain 1 writes `1` (incr), then Domain 2 overwrites it with `-1` (decr). The stack has 1 element but `size` is [**-1**]{.bug}.
>
> **Note:** this bug is actually a scheduler issue: a bad interleaving. It can happen on any architecture, without any compiler or hardware reordering. The data race classification still matters: with non-atomic accesses, OCaml could also produce even weirder behaviors on top of this.
