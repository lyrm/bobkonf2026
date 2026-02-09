open QCheck
(** Sequential and Parallel model-based tests of spsc_queue *)

open STM
open Util

module Spec = struct
  type cmd = Push of int | Pop

  let show_cmd c =
    match c with Push i -> "Push " ^ string_of_int i | Pop -> "Pop"

  type state = int * int list
  type sut = int Spsc_queue.t

  let producer_cmd _s =
    let int_gen = Gen.nat in
    QCheck.make ~print:show_cmd (Gen.map (fun i -> Push i) int_gen)

  let consumer_cmd _s =
    QCheck.make ~print:show_cmd (Gen.oneof [ Gen.return Pop ])

  let arb_cmd _s =
    let int_gen = Gen.nat in
    QCheck.make ~print:show_cmd
      (Gen.oneof [ Gen.return Pop; Gen.map (fun i -> Push i) int_gen ])

  let size_exponent = 4
  let max_size = Int.shift_left 1 size_exponent
  let init_state = (0, [])
  let init_sut () = Spsc_queue.create ~size_exponent
  let cleanup _ = ()

  let next_state c (n, s) =
    match c with
    | Push i -> if n = max_size then (n, s) else (n + 1, i :: s)
    | Pop -> (
        match List.rev s with [] -> (0, s) | _ :: s' -> (n - 1, List.rev s'))

  let precond _ _ = true

  let run c d =
    match c with
    | Push i -> Res (bool, Spsc_queue.try_push d i)
    | Pop -> Res (option int, Spsc_queue.pop_opt d)

  let postcond c ((n, s) : state) res =
    match (c, res) with
    | Push _, Res ((Bool, _), res) -> (
        match res with false -> n = max_size | true -> n < max_size)
    | Pop, Res ((Option Int, _), res) -> (
        match (res, List.rev s) with
        | None, [] -> true
        | Some popped, x :: _ -> x = popped
        | _ -> false)
    | _, _ -> false
end

let run ~count ~name =
  let module Seq = STM_sequential.Make (Spec) in
  let module Dom = struct
    module Spec = Spec
    include STM_domain.Make (Spec)
  end in
  let make_domain ~count ~name =
    (* [arb_cmds_par] differs in what each triple component generates:
         "Producer domain" cmds can't be [Pop], "consumer domain" cmds can only be [Pop]. *)
    let arb_cmds_par =
      Dom.arb_triple 20 12 Spec.producer_cmd Spec.producer_cmd Spec.consumer_cmd
    in
    (* A parallel agreement test - w/repeat and retries combined *)
    let agree_test_par_asym ~count ~name =
      let rep_count = 20 in
      Test.make ~retries:10 ~count ~name:(name ^ " parallel") arb_cmds_par
      @@ fun triple ->
      assume (Dom.all_interleavings_ok triple);
      repeat rep_count Dom.agree_prop_par_asym triple
    in
    [
      agree_test_par_asym ~count ~name;
      (* Note: this can generate, e.g., pop commands/actions in different threads, thus violating the spec. *)
      Dom.neg_agree_test_par ~count ~name:(name ^ " parallel, negative");
    ]
  in
  let module Seq = STM_sequential.Make (Spec) in
  let module Dom = struct
    module Spec = Spec
    include STM_domain.Make (Spec)
  end in
  QCheck_base_runner.run_tests
    (List.concat
       [
         [ Seq.agree_test ~count ~name:(name ^ " sequential") ];
         make_domain ~count ~name;
       ])

let () =
  let exit_code = run ~count:500 ~name:"qcheck_stm" in
  exit exit_code
