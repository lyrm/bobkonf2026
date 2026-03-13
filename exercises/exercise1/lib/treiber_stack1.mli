@@ portable

type ('a : value mod contended portable) t : value mod contended portable
(** Represents a lock-free Treiber stack holding elements of type ['a]. *)

val create : unit -> 'a t
(** [create ()] creates a new empty Treiber stack. *)

val pop_opt : 'a t -> 'a option
(** [pop_opt stack] removes and returns [Some] of the top element of the
    [stack], or [None] if the [stack] is empty. *)

val push : 'a t -> 'a -> unit
(** [push stack element] adds [element] to the top of the [stack]. *)

val size : 'a t -> int
(** [size stack] returns the number of elements currently in the [stack]. *)
