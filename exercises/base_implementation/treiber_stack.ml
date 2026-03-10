(** Treiber's Lock Free stack *)

type 'a t = { stack : 'a list Atomic.t }

let create () = { stack = Atomic.make [] }

let rec pop_opt_ t backoff =
  match Atomic.get t.stack with
  | [] -> None
  | hd :: tail as before ->
      if Atomic.compare_and_set t.stack before tail then Some hd
      else pop_opt_ t (Backoff.once backoff)

let pop_opt t = pop_opt_ t Backoff.default

let rec push_ t value backoff =
  let before = Atomic.get t.stack in
  let after = value :: before in
  if Atomic.compare_and_set t.stack before after then ()
  else push_ t value (Backoff.once backoff)

let push t value = push_ t value Backoff.default
