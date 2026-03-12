(** [repeat n test] runs the [test] function [n] times and returns [true] if all
    runs returned [true]. *)
let repeat n test =
  List.init n (fun _ -> test ()) |> List.for_all (fun res -> res)

(** [drain_all] is a utility function that extracts the content of the
    [stack] into a list. *)
let drain_all pop_opt stack =
  let rec aux acc =
    match pop_opt stack with None -> acc | Some elt -> aux (elt :: acc)
  in
  aux []

module Barrier = Barrier
