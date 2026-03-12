module Stack = Treiber_stack2

(* This shadows [Stdlib.Atomic] with dscheck's instrumented version,
   so that the stack implementation's atomic operations are traced. *)
module Dscheck = Dscheck.TracedAtomic

let drain_all stack = Utils.drain_all Stack.pop_opt stack

let test_push_pop () =
  (* [Dscheck.trace] is the entry point: it runs the test body repeatedly,
     exploring all possible interleavings of atomic operations. *)
  try
    Dscheck.trace (fun () ->
        let stack = Stack.create () in

        (* [Dscheck.spawn] declares a function to run as a separate domain.
           Contrary to [Domain.spawn], no actual domain is created: dscheck
           simulates concurrency by exploring all possible interleavings of atomic
           operations across spawned functions. *)
        Dscheck.spawn (fun () -> Stack.push stack 1);

        (* A plain ref is fine here: dscheck runs everything sequentially. *)
        let popped = ref None in
        Dscheck.spawn (fun () -> popped := Stack.pop_opt stack);

        (* [Dscheck.final] contains what should be done at the end of each
         interleaving, in particular which checks to perform under Dscheck.check.*)
        Dscheck.final (fun () ->
            Dscheck.check (fun () ->
                let remaining = drain_all stack in
                match (!popped, remaining) with
                | Some 1, [] -> true
                | None, [ 1 ] -> true
                | _ -> false)))
  with Assert_failure _ -> Alcotest.fail "dscheck found an assertion violation"

(* 3.1 TODO Translate the failing test you found with qcheck-lin here *)
(*
let test_my_bug () =
  try
    Dscheck.trace (fun () ->
        let stack = Stack.create () in

        (* Any sequential operation should be added here. *)

        Dscheck.spawn (fun () ->
            (* Operations performed by the first domain *)
          );

        Dscheck.spawn (fun () ->
            (* Operation performed by the second domain *)
          );

        Dscheck.final (fun () ->
            Dscheck.check (fun () ->
                (* The property you want to check for *)
                true)))
  with Assert_failure _ -> Alcotest.fail "dscheck found an assertion violation"
*)

let () =
  let open Alcotest in
  run "Dscheck_tests"
    [
      ( "basic",
        (* Additional test should be added in the following list *)
        [
          test_case "push_pop" `Slow test_push_pop
          (* 3.1 TODO uncomment the following line *)
          (* test_case "exercise 2 bug" `Slow test_my_bug; *);
        ] );
    ]
