(*
 * mew.ml
 * -----------
 * Copyright : (c) 2019, ZAN DoYe <zandoye@gmail.com>
 * Licence   : MIT
 *
 * This file is a part of mew.
 *)

module Make (Modal:Modal.S) (Concurrent:Concurrent.S) =
struct

  class edit state= object
    val state= state

  end

  class state= object(self)
    method edit= new edit self
  end
end

