(*
 * modal.ml
 * -----------
 * Copyright : (c) 2019, ZAN DoYe <zandoye@gmail.com>
 * Licence   : MIT
 *
 * This file is a part of mew.
 *)

module type S = sig
  module Key : Key.S
  module Mode : module type of Mode.Make(Key)
end

