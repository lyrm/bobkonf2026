{pause}

### The tools exist

<style>
.tool-columns {
  display: flex;
  gap: 2em;
}
.tool-columns > :first-child {
  flex: 1;
  text-align: right;
}
.tool-columns > :last-child {
  flex: 2;
}
</style>

{.tool-columns}
---

> **TSan**
>
> **qcheck-lin** / **qcheck-stm**
>
> **dscheck**

> Detects data races at runtime
>
> Generates concurrent tests automatically
>
> Model-checks all interleavings of atomic operations

---
 

{pause}

### But some are still maturing

Especially **dscheck** :  powerful but still young
- limited documentation, 
- does not work on project with other synchronization mechanism like mutexes, condition variables, etc.

{pause}

### A good process

1. **Generate tests** with qcheck-lin (or qcheck-stm for richer specifications)
2. **Run them with TSan** to catch data races
3. **Feed failing scenarios to dscheck** to get a full trace of the bug

{pause up}
### But, what about the size function?

See this [paper](https://arxiv.org/pdf/2209.07100): it is actually not easy to add a size function to a lockfree algorithm. 

But, also, it does increase contention on the stack, the following will work:

```ocaml
type 'a s = { stack : 'a list; size : int }
type 'a t = 'a s Atomic.t
```
<!-- let create () = Atomic.make { stack = []; size = 0 }
let size t = (Atomic.get t).size

let rec pop_opt_ t backoff =
  match Atomic.get t with
  | { stack = []; size = _ } -> None
  | { stack = hd :: tail; size } as before ->
      if Atomic.compare_and_set t before { stack = tail; size = size - 1 } then
        Some hd
      else pop_opt_ t (Backoff.once backoff)

let pop_opt t = pop_opt_ t Backoff.default

let rec push_ t value backoff =
  let before = Atomic.get t in
  let after = { stack = value :: before.stack; size = before.size + 1 } in
  if Atomic.compare_and_set t before after then ()
  else push_ t value (Backoff.once backoff)

let push t value = push_ t value Backoff.default

``` -->