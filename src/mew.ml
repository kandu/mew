(*
 * mew.ml
 * -----------
 * Copyright : (c) 2019, ZAN DoYe <zandoye@gmail.com>
 * Licence   : MIT
 *
 * This file is a part of mew.
 *)

module Make (Key:Key.S) (Concurrent:Concurrent.S) =
struct
  type t= {
    mode: Mode.t
  }
end

