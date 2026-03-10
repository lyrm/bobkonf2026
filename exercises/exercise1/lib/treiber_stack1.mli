(** Lock-free multi-producer multi-consumer Treiber stack.

    All functions are lock-free. It is the recommended starting point when
    needing a LIFO structure. *)

(** {1 API} *)

type 'a t
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

(** {1 Examples} *)

(** {2 Sequential example}
    An example top-level session:
    {[
      # open Treiber_stack1
      # let t : int t = create ()
      val t : int t = <abstr>
      # push t 42
      - : unit = ()
      # push t 1
      - : unit = ()
      # pop_opt t
      - : int option = Some 1
      # pop_opt t
      - : int option = Some 42
      # pop_opt t
      - : int option = None
    ]} *)

(** {2 Multicore example}
    Note: The barrier is used in this example solely to make the results more
    interesting by increasing the likelihood of parallelism. Spawning a domain
    is a costly operation, especially compared to the relatively small amount of
    work being performed here. In practice, using a barrier in this manner is
    unnecessary.

    {@ocaml non-deterministic=command[
      # open Treiber_stack1
      # let t : int t = create ()
      val t : int t = <abstr>
      # let pusher () =
          push t 1;
          push t 2;
          push t 3
      val pusher : unit -> unit = <fun>

      # let popper () =
          List.init 5 (fun i -> pop_opt t)
      val popper : unit -> int option list = <fun>

      # let domain_pusher = Domain.spawn pusher
      val domain_pusher : unit Domain.t = <abstr>
      # let domain_popper = Domain.spawn popper
      val domain_popper : int option list Domain.t = <abstr>
      # Domain.join domain_pusher
      - : unit = ()
      # Domain.join domain_popper
      - : int option list = [Some 1; Some 3; Some 2; None; None]
      (* Depending on the interleaving, you could have something else here,
      but it should respect the LIFO order of the stack. *)
    ]} *)
