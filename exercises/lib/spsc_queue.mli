type 'a t
(** Represents a single-producer single-consumer non-resizable queue that works
    in FIFO order. *)

val create : size_exponent:int -> 'a t
(** [create ~size_exponent] creates a new single-producer single-consumer queue
    with a maximum size of [2^size_exponent] and initially empty.

    🐌 This is a linear-time operation in [2^size_exponent]. *)

val try_push : 'a t -> 'a -> bool
(** [try_push queue elt] tries to add the element [elt] at the end of the
    [queue]. If the queue [q] is full, [false] is returned. This method can be
    used by at most one domain at a time. *)

val pop_opt : 'a t -> 'a option
(** [pop_opt queue] removes and returns [Some] of the first element of the
    [queue], or [None] if the queue is empty. This method can be used by at most
    one domain at a time. *)

val peek_opt : 'a t -> 'a option
(** [peek_opt queue] returns [Some] of the first element of the [queue] without
    removing it, or [None] if the queue is empty. This method can be used by at
    most one domain at a time. *)

val length : 'a t -> int
(** [length queue] returns the number of elements currently in the [queue]. *)
