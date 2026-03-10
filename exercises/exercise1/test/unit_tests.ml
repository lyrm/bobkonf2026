(* Utils contains `drain_all`, `repeat` and the Barrier module. *)
open Utils
module Stack = Treiber_stack1

let drain_all stack = Utils.drain_all Stack.pop_opt stack

let ( let* ) spawn_result f =
  match spawn_result with
  | Multicore.Spawned -> f ()
  | Failed ((), _exn, _backtrace) -> assert false

let test_push_pop (() : unit) : bool =
  let stack = Stack.create () in
  let barrier = Barrier.create 2 in

  (* Work to run on the first domain (i.e. thread). *)
  let prod_work () =
    Barrier.await barrier;
    Stack.push stack 42
  in

  (* Work to run on the second domain. *)
  let popped = ref None in
  let cons_work () =
    Barrier.await barrier;
    popped := Stack.pop_opt stack
  in

  (* Spawning the domains *)
  let* () = Multicore.spawn (fun () -> prod_work ()) () in
  let* () = Multicore.spawn (fun () -> cons_work ()) () in

  (* Properties that should hold after both domains finish *)
  let remaining = drain_all stack in

  match (!popped, remaining) with
  | Some 42, [] | None, [ 42 ] -> true
  | _ -> false

let () =
  let result = test_push_pop () in
  Printf.printf "test_push_pop: %s\n" (if result then "PASSED" else "FAILED");
  if not result then exit 1
