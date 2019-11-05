(*
 * mode.ml
 * -----------
 * Copyright : (c) 2019, ZAN DoYe <zandoye@gmail.com>
 * Licence   : MIT
 *
 * This file is a part of mew.
 *)

module type S = sig
  type t
  type modes

  val name : t -> string
  val compare : t -> t -> int
end

