(* Utils contains `drain_all`, `repeat` and the Barrier module. *)
open Utils
module Stack = Treiber_stack2

let drain_all stack = Utils.drain_all Stack.pop_opt stack

let test_push_pop () =
  let stack = Stack.create () in
  let barrier = Barrier.create 2 in

  (* Work to run on the first domain (i.e. thread). *)
  let prod_work () =
    Barrier.await barrier;
    Stack.push stack 1;
    Stack.push stack 2;
    Stack.push stack 3
  in

  (* Work to run on the second domain. *)
  let cons_work () =
    Barrier.await barrier;
    let _ = Stack.pop_opt stack in
    let _ = Stack.pop_opt stack in
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
  let size = Stack.size stack in
  let remaining = drain_all stack in
  let len_remaining = List.length remaining in
  size = len_remaining

(* The following is the infrastructure to launch the tests using Alcotest,
   which gives us a nice output. *)
let () =
  let nrepeat = 10000 in
  let open Alcotest in
  run "Exercise2"
    [
      ( "parallel_tests",
        [
          test_case "push_pop_once" `Quick (fun () ->
              check bool "true" true (repeat nrepeat test_push_pop));
        ] );
    ]
