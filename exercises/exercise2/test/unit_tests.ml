(* Utils contains  `repeat` and the Barrier module. *)
open Utils
module Stack = Treiber_stack2

let drain_all stack = Utils.drain_all Stack.pop_opt stack

let ( let* ) spawn_result f =
  match spawn_result with
  | Multicore.Spawned -> f ()
  | Failed ((), _exn, _backtrace) -> assert false

let test_push_pop (() : unit) : bool =
  let stack = Stack.create () in
  let barrier = Barrier.create 2 in

  (* Work to run on the first domain (i.e. thread). *)
  let prod_work : _ @ portable = fun () ->
    Barrier.await barrier;
    Stack.push stack 42
  in

  (* Work to run on the second domain. *)
  let cons_work : _ @ portable = fun () ->
    Barrier.await barrier;
    Stack.pop_opt stack |> ignore
  in

  (* Spawning the domains *)
  let* () = Multicore.spawn prod_work () in
  let* () = Multicore.spawn cons_work () in

  (* Properties that should hold after both domains finish *)
  let remaining = drain_all stack in
  let size = Stack.size stack in
  size = List.length remaining 

let () =
  let result = test_push_pop () in
  Printf.printf "test_push_pop: %s\n" (if result then "PASSED" else "FAILED");
  if not result then exit 1
