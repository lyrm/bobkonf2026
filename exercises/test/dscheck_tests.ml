module Dscheck = Dscheck.TracedAtomic
module Queue = Spsc_queue

let drain_all queue =
  let rec loop acc =
    match Queue.pop_opt queue with None -> acc | Some v -> loop (v :: acc)
  in
  loop []

(* Both domains push in parallel without reaching the queue's capacity: 
can't work because it's a  single producer single consumer queue *)
(* let test_push_push () =
  Dscheck.trace (fun () ->
      let queue = Queue.create ~size_exponent:6 in
      let items_total = 6 in

      Dscheck.spawn (fun () ->
          for i = 1 to items_total do
            Queue.try_push queue i |> ignore
          done);

      Dscheck.spawn (fun () ->
          for i = 1 to items_total do
            Queue.try_push queue (i * 100) |> ignore
          done);

      Dscheck.final (fun () ->
          Dscheck.check (fun () ->
              let items = drain_all queue |> List.rev in
              let _items1 = List.filter (fun x -> x < 100) items in
              let _items2 = List.filter (fun x -> x >= 100) items in
              let size = List.length items in
              size = items_total * 2))) *)

let test_push_pop () =
  Dscheck.trace (fun () ->
      let queue = Queue.create ~size_exponent:6 in
      let items_total = 4 in
      let elt_to_push = List.init items_total (fun i -> i + 1) in

      Dscheck.spawn (fun () ->
          List.iter (fun elt -> Queue.try_push queue elt |> ignore) elt_to_push);

      let popped = ref [] in
      Dscheck.spawn (fun () ->
          for _ = 1 to items_total do
            match Queue.pop_opt queue with
            | None -> ()
            | Some elt -> popped := elt :: !popped
          done);

      Dscheck.final (fun () ->
          Dscheck.check (fun () ->
              let remaining = drain_all queue in
              List.length !popped + List.length remaining = items_total
              && remaining @ !popped |> List.rev = elt_to_push)))

let () =
  let open Alcotest in
  run "Dscheck_tests"
    [ ("basic", [ test_case "push_pop" `Slow test_push_pop ]) ]
