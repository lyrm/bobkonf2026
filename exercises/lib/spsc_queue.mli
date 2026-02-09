type 'a t

exception Full
exception Empty

val create : size_exponent:int -> 'a t
val try_push : 'a t -> 'a -> bool
val pop_opt : 'a t -> 'a option
val peek_opt : 'a t -> 'a option
val length : 'a t -> int
