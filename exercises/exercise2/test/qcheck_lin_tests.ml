(* qcheck-lin linearizability test for Treiber_stack2.
   The [api] list below describes which functions to test.*)
module Stack = Treiber_stack2

module StackSig = struct
  type t = int Stack.t

  let init () = Stack.create ()
  let cleanup _ = ()

  open Lin

  let a = Lin.int

  let api =
    [
      val_ "Stack.push" Stack.push (t @-> a @-> returning unit);
      val_ "Stack.pop_opt" Stack.pop_opt (t @-> returning (option a));
    ]
end

module S = Lin_domain.Make (StackSig);;

QCheck_base_runner.run_tests_main
  [ S.lin_test ~count:500 ~name:"Lin Stack test" ]
