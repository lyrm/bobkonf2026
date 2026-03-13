(** Treiber's Lock Free stack *)

type ('a : value mod contended portable) t : value mod contended portable = {
  stack : 'a list Atomic.t;
  size : int Atomic.t;
}

let create () = { stack = Atomic.make []; size = Atomic.make 0 }

let rec pop_opt_ t backoff =
  match Atomic.get t.stack with
  | [] -> None
  | hd :: tail as before ->
      if Atomic.compare_and_set t.stack before tail then (
        Atomic.decr t.size;
        Some hd)
      else pop_opt_ t (Backoff.once backoff)

let pop_opt t = pop_opt_ t Backoff.default

let rec push_ t value backoff =
  let before = Atomic.get t.stack in
  let after = value :: before in
  if Atomic.compare_and_set t.stack before after then Atomic.incr t.size
  else push_ t value (Backoff.once backoff)

let push t value = push_ t value Backoff.default
let size t = Atomic.get t.size
