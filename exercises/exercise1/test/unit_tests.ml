(* Utils contains  `repeat` and the Barrier module. *)
open Utils
module Stack = Treiber_stack1

(** [drain_all stack] returns all the remaining elements of the stack in the
    same order (head of the list = top of the stack) *)
(* let drain_all stack = Utils.drain_all Stack.pop_opt stack
 *)

let test_push_pop (() : unit) : bool =
  let stack = Stack.create () in
  let barrier = Barrier.create 2 in

  (* Work to run on the first domain (i.e. thread). *)
  let prod_work () =
    (* The barrier prevents each domain from starting its work before
       the other domain is ready, increasing the likelihood of them
       running concurrently. *)
    Barrier.await barrier;
    (* 2.2 TODO add more operations here *)
    Stack.push stack 42
  in

  (* Work to run on the second domain. *)
  let cons_work () =
    Barrier.await barrier;
    (* 2.2 TODO add more operations here *)
    let _ = Stack.pop_opt stack in
    ()
  in

  (* Spawning the domains *)
  let producer = Domain.spawn prod_work in
  let consumer = Domain.spawn cons_work in

  (* [Domain.join] is a blocking function that waits for the domain to finish 
  its work *)
  let () = Domain.join producer in
  let () = Domain.join consumer in

  (* Properties that should hold after both domains finish *)
  (* 1. TODO : replace the following line to check that the value returned by 
  `Stack.size` is correct.

  Tip: You can use the function `drain_all` that is commented at the start of 
  this file. *)
  true

(* The following is the infrastructure to launch the tests using Alcotest,
   which gives us a nice output. *)
let () =
  let open Alcotest in
  run "Exercise1"
    [
      ( "parallel_tests",
        [
          test_case "push_pop_once" `Quick (fun () ->
              check bool "true" true
                ((* 2.1 TODO Repeat the test using `Utils.repeat` here. *)
                 test_push_pop ()));
        ] );
    ]
