
type 'a t
(** Represents a lock-free Treiber stack holding elements of type ['a]. *)

val create : unit -> 'a t 
(** [create ()] creates a new empty Treiber stack. *)

val pop_opt : 'a t -> 'a option @ portable
(** [pop_opt stack] removes and returns [Some] of the top element of the
    [stack], or [None] if the [stack] is empty. *)

val push : 'a t -> 'a -> unit @ portable
(** [push stack element] adds [element] to the top of the [stack]. *)

val size : 'a t -> int @ portable
(** [size stack] returns the number of elements currently in the [stack]. *)
