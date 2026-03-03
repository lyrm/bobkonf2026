module Stack = Treiber_stack2

(* This shadows [Stdlib.Atomic] with dscheck's instrumented version,
   so that the stack implementation's atomic operations are traced. *)
module Dscheck = Dscheck.TracedAtomic

let drain_all stack = Utils.drain_all Stack.pop_opt stack

let test_push_pop () =
  (* [Dscheck.trace] is the entry point: it runs the test body repeatedly,
     exploring all possible interleavings of atomic operations. *)
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

let () =
  let open Alcotest in
  run "Dscheck_tests"
    [
      ( "basic",
        (* Additional test should be added in the following list *)
        [ test_case "push_pop" `Slow test_push_pop ] );
    ]
