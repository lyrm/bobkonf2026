### Solution of exercise 2: `push` and `pop` are not linearizable

<style>
.interleaving {
  font-size: 0.85em;
}
.interleaving table {
  border-collapse: collapse;
  width: 100%;
}
.interleaving th, .interleaving td {
  padding: 0.3em 0.6em;
  text-align: left;
  border-bottom: 1px solid #ddd;
}
.interleaving th {
  font-weight: bold;
  border-bottom: 2px solid #888;
}
.interleaving .bug {
  color: crimson;
  font-weight: bold;
}
.interleaving .pop {
  color: #2e7d32;
}
.interleaving .size {
  color: #1565c0;
}
</style>

{.block .interleaving}
> | Step | Domain 1 (`push 1`) | Domain 2 ([`pop`]{.pop}, [`size`]{.size}) | `stack` | `size` |
> |------|---------------------|--------------------------|---------|--------|
> | 1 | `Atomic.compare_and_set stack [1]` | | `[1]` | 0 |
> | 2 | | [`Atomic.compare_and_set stack []`]{.pop} | `[]` | 0 |
> | 3 | | [`Atomic.decr size`]{.pop} | `[]` | [**-1**]{.bug} |
> | 4 | | [`Atomic.get size`]{.size} | `[]` | [**-1**]{.bug} |
> | 5 | `Atomic.incr size` | | `[]` | 0 |

{pause}

{.block .box}
> **Not linearizable:** after [`pop`]{.pop} succeeds (step 2), `size` is decremented to [**-1**]{.bug} (step 3). Then [`size`]{.size} observes this impossible value (step 4). The `push` increment hasn't happened yet, so `size` temporarily goes negative.

{pause up}
### A better implementation ?

[*Concurrent Size*, Sela and Petrank 2022](https://arxiv.org/pdf/2209.07100): it is actually not easy to add an efficient size function to a lockfree algorithm. 

{pause}

But, also, it does increase contention on the stack, the following will work:

```ocaml
type 'a s = { stack : 'a list; size : int }
type 'a t = 'a s Atomic.t
```
{pause}
```ocaml
let create () = Atomic.make { stack = []; size = 0 }
let size t = (Atomic.get t).size

let rec pop_opt_ t backoff =
  match Atomic.get t with
  | { stack = []; size = _ } -> None
  | { stack = hd :: tail; size } as before ->
      if Atomic.compare_and_set t before { stack = tail; size = size - 1 } then
        Some hd
      else pop_opt_ t (Backoff.once backoff)

let pop_opt t = pop_opt_ t Backoff.default

let rec push_ t v backoff =
  let before = Atomic.get t in
  let after = { stack = v :: before.stack; size = before.size + 1 } in
  if Atomic.compare_and_set t before after then ()
  else push_ t v (Backoff.once backoff)

let push t v = push_ t v Backoff.default

```