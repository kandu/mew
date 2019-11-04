module type S = sig
  type 'a t

  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val return : 'a -> 'a t

  val both : 'a t -> 'b t -> ('a * 'b) t
  val join : unit t list -> unit t

  val pick : 'a t list -> 'a t
  val choose : 'a t list -> 'a t

  val async : 'a t-> unit
  val cancel : 'a t-> unit

  val sleep : float -> unit t

  val run : 'a t -> 'a
end

