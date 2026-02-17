module Queue = Spsc_queue

let drain_all queue =
  let rec loop acc =
    match Queue.pop_opt queue with None -> acc | Some v -> loop (v :: acc)
  in
  loop []

let test_push_pop () =
  let queue = Queue.create ~size_exponent:6 in
  let _barrier = Barrier.create 2 in
  let items_total = 10 in
  let elt_to_push = List.init items_total (fun i -> i + 1) in

  let producer =
    Domain.spawn (fun () ->
        Barrier.await _barrier;
        List.iter (fun elt -> Queue.try_push queue elt |> ignore) elt_to_push)
  in

  let popped = ref [] in
  let consumer =
    Domain.spawn (fun () ->
        Barrier.await _barrier;
        for _ = 1 to items_total do
          match Queue.pop_opt queue with
          | None -> ()
          | Some elt -> popped := elt :: !popped
        done)
  in

  Domain.join producer;
  Domain.join consumer;

  (* Some properties we want to check *)
  let remaining = drain_all queue in
  List.length !popped + List.length remaining = items_total
  && remaining @ !popped |> List.rev = elt_to_push

let repeat n test =
  List.init n (fun _ -> test ()) |> List.for_all (fun res -> res)

(* This is just the infrastructure to launch the tests *)
let () =
  let open Alcotest in
  run "Qcheck_tests"
    [
      ( "parallel_tests",
        [
          test_case "push_pop" `Quick (fun () ->
              check bool "true" true (repeat 10 test_push_pop));
        ] );
    ]
