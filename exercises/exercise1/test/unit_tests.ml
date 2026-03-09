(* Utils contains `drain_all`, `repeat` and the Barrier module. *)
open Utils
module Stack = Treiber_stack1

let drain_all stack = Utils.drain_all Stack.pop_opt stack

let test_push_pop (() : unit) : bool =
  let stack = Stack.create () in
  let barrier = Barrier.create 2 in

  (* Work to run on the first domain (i.e. thread). *)
  let prod_work () =
    (* The barrier prevents each domain from starting its work before
       the other domain is ready, increasing the likelihood of them
       running concurrently. *)
    Barrier.await barrier;
    Stack.push stack 42
  in

  (* Work to run on the second domain. *)
  let cons_work () =
    Barrier.await barrier;
    Stack.pop_opt stack
  in

  (* Spawning the domains *)
  let producer = Domain.spawn prod_work in
  let consumer = Domain.spawn cons_work in

  (* [Domain.join] is a blocking function that waits for the domain to finish 
  its work *)
  let () = Domain.join producer in
  let popped = Domain.join consumer in

  (* Properties that should hold after both domains finish *)
  let remaining = drain_all stack in

  match (popped, remaining) with
  | Some 42, [] | None, [ 42 ] -> true
  | _ -> false

(* The following is the infrastructure to launch the tests using Alcotest,
   which gives us a nice output. *)
let () =
  let open Alcotest in
  run "Exercise1"
    [
      ( "parallel_tests",
        [
          test_case "push_pop_once" `Quick (fun () ->
              check bool "true" true (test_push_pop ()));
        ] );
    ]
