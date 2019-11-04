module type S = sig
  type t

  type code
  type modifier
  type modifiers

  val create : code:code -> modifiers:modifiers -> t
  val create_modifiers : modifier list -> modifiers

  val code : t -> code
  val modifiers : t -> modifiers
  val modifier : key:t -> modifier:modifier -> bool

  val compare : t -> t -> int
  val compare_code : code -> code -> int
  val compare_modifier : modifier -> modifier -> int

  val to_string : t -> string
end

