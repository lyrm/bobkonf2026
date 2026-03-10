@@portable 

type t : value mod contended portable

val create : int -> t 
(** [create c] returns a barrier of capacity [c]. *)

val await : t -> unit
(** A domain calling [await barrier] will only be able to progress past this
    function once the number of domains waiting at the barrier is egal to its
    capacity . *)
