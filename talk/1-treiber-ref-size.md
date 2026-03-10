
{carousel change-page='~n:"all"'}
----

> <!-- original implem -->
> ```ocaml
> type 'a t = { stack : 'a list Atomic.t }
> let create () = { stack = Atomic.make []}
> 
>
> let rec push_ t v backoff =
> let before = Atomic.get t.stack in
>  let after = v :: before in
>  if Atomic.compare_and_set t.stack before after then 
>    ()
>  else 
>    push_ t v (Backoff.once backoff)
>
> let push t v = push_ t v Backoff.default
> 
> let rec pop_opt_ t backoff =
>  match Atomic.get t.stack with
>  | [] -> None
>  | hd :: tail as before ->
>    if Atomic.compare_and_set t.stack before tail then 
>        Some hd
>    else
>        pop_opt_ t (Backoff.once backoff)
>
> let pop_opt t = pop_opt_ t Backoff.default
>```

> <!-- change type -->
> ```ocaml
> type 'a t = { stack : 'a list Atomic.t; size : int ref }
> let create () = { stack = Atomic.make []; size = ref 0 }
>
>
> let rec push_ t v backoff =
> let before = Atomic.get t.stack in
>  let after = v :: before in
>  if Atomic.compare_and_set t.stack before after then 
>    ()
>  else 
>    push_ t v (Backoff.once backoff)
>
> let push t v = push_ t v Backoff.default
> 
> let rec pop_opt_ t backoff =
>  match Atomic.get t.stack with
>  | [] -> None
>  | hd :: tail as before ->
>    if Atomic.compare_and_set t.stack before tail then 
>        Some hd
>    else
>        pop_opt_ t (Backoff.once backoff)
>
> let pop_opt t = pop_opt_ t Backoff.default
>```

> <!-- add size  -->
> ```ocaml
> type 'a t = { stack : 'a list Atomic.t; size : int ref }
> let create () = { stack = Atomic.make []; size = ref 0 }
> let size t = !(t.size)
>
> let rec push_ t v backoff =
> let before = Atomic.get t.stack in
>  let after = v :: before in
>  if Atomic.compare_and_set t.stack before after then 
>    ()
>  else 
>    push_ t v (Backoff.once backoff)
>
> let push t v = push_ t v Backoff.default
> 
> let rec pop_opt_ t backoff =
>  match Atomic.get t.stack with
>  | [] -> None
>  | hd :: tail as before ->
>    if Atomic.compare_and_set t.stack before tail then 
>        Some hd
>    else
>        pop_opt_ t (Backoff.once backoff)
>
> let pop_opt t = pop_opt_ t Backoff.default
>```

> <!-- Correct push -->
> ```ocaml
> type 'a t = { stack : 'a list Atomic.t; size : int ref }
> let create () = { stack = Atomic.make []; size = ref 0 }
> let size t = !(t.size)
>
> let rec push_ t v backoff =
> let before = Atomic.get t.stack in
>  let after = v :: before in
>  if Atomic.compare_and_set t.stack before after then 
>    incr t.size
>  else 
>    push_ t v (Backoff.once backoff)
>
> let push t v = push_ t v Backoff.default
> 
> let rec pop_opt_ t backoff =
>  match Atomic.get t.stack with
>  | [] -> None
>  | hd :: tail as before ->
>    if Atomic.compare_and_set t.stack before tail then 
>        Some hd
>    else
>        pop_opt_ t (Backoff.once backoff)
>
> let pop_opt t = pop_opt_ t Backoff.default
>```

> <!-- Correct pop -->
> ```ocaml
> type 'a t = { stack : 'a list Atomic.t; size : int ref }
> let create () = { stack = Atomic.make []; size = ref 0 }
> let size t = !(t.size)
>
> let rec push_ t v backoff =
> let before = Atomic.get t.stack in
>  let after = v :: before in
>  if Atomic.compare_and_set t.stack before after then 
>    incr t.size
>  else 
>    push_ t v (Backoff.once backoff)
>
> let push t v = push_ t v Backoff.default
> 
> let rec pop_opt_ t backoff =
>  match Atomic.get t.stack with
>  | [] -> None
>  | hd :: tail as before ->
>    if Atomic.compare_and_set t.stack before tail then (
>        decr t.size;
>        Some hd)
>    else
>        pop_opt_ t (Backoff.once backoff)
>
> let pop_opt t = pop_opt_ t Backoff.default
>```