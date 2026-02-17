(*
 * Copyright (c) 2022, Bartosz Modelski
 * Copyright (c) 2024, Vesa Karvonen
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(* Single producer single consumer queue
 *
 * The algorithms here are inspired by:

 * https://dl.acm.org/doi/pdf/10.1145/3437801.3441583
 *)

type 'a t = {
  array : 'a Option.t Array.t;
  tail : int Atomic.t;
  mutable tail_cache : int;
  head : int Atomic.t;
  mutable head_cache : int;
}

exception Full
exception Empty

(* *)
let create ~size_exponent =
  if size_exponent < 0 || Sys.int_size - 2 < size_exponent then
    invalid_arg "size_exponent out of range";
  let size = 1 lsl size_exponent in
  let array = Array.make size None in
  let tail = Atomic.make_contended 0 in
  let tail_cache = 0 in
  let head = Atomic.make_contended 0 in
  let head_cache = 0 in
  { array; tail; tail_cache; head; head_cache }

(* *)
let try_push t element =
  let size = Array.length t.array in
  let tail = Atomic.get t.tail in
  let head_cache = t.head_cache in

  if
    head_cache == tail - size
    &&
    let head = Atomic.get t.head in
    t.head_cache <- head;
    head == head_cache
  then false
  else begin
    (* First possible race conditions: exchange incr and set (it should be first set than incr) *)
    Atomic.incr t.tail;
    Array.set t.array (tail land (size - 1)) (Some element);
    true
  end

let pop_opt t =
  let head = Atomic.get t.head in
  let tail_cache = t.tail_cache in
  if
    head == tail_cache
    &&
    let tail = Atomic.get t.tail in
    t.tail_cache <- tail;
    tail_cache == tail
  then None
  else
    let index = head land (Array.length t.array - 1) in
    let v = Array.get t.array index in
    Array.set t.array index None;
    Atomic.incr t.head;
    v

let peek_opt t =
  let head = Atomic.get t.head in
  let tail_cache = t.tail_cache in
  if
    head == tail_cache
    &&
    let tail = Atomic.get t.tail in
    t.tail_cache <- tail;
    tail_cache == tail
  then None
  else
    let index = head land (Array.length t.array - 1) in
    let v = Array.get t.array index in
    v

let length t =
  let tail = Atomic.get t.tail in
  let head = Atomic.get t.head in
  (* data races *)
  t.head_cache <- head;
  t.tail_cache <- tail;
  tail - head
