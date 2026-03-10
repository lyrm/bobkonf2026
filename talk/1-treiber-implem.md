 ### Implementation


```ocaml
type 'a t = { stack : 'a list Atomic.t }
```
{pause}
```ocaml
let create () = { stack = Atomic.make [] }
```
{pause}
```ocaml
let rec push_ t v backoff =
  let before = Atomic.get t.stack in
  let after = v :: before in
  if Atomic.compare_and_set t.stack before after then ()
  else push_ t v (Backoff.once backoff)

let push t v = push_ t v Backoff.default
```
{pause}
```ocaml
let rec pop_opt_ t backoff =
  match Atomic.get t.stack with
  | [] -> None
  | hd :: tail as before ->
    if Atomic.compare_and_set t.stack before tail then
        Some hd
    else
        pop_opt_ t (Backoff.once backoff)

let pop_opt t = pop_opt_ t Backoff.default
```
