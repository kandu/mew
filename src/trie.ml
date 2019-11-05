(*
 * trie.ml
 * -----------
 * Copyright : (c) 2019, ZAN DoYe <zandoye@gmail.com>
 * Licence   : MIT
 *
 * This file is a part of mew.
 *)

module type S = sig
  type path
  type 'a node
  val create : 'a option -> 'a node
  val get : 'a node -> path list -> 'a option
  val set : 'a node -> path list -> 'a -> unit
  val unset : 'a node -> path list -> unit
  val sub: 'a node -> path list -> 'a node option
end

module Make (H:Hashtbl.HashedType): (S with type path:= H.t) = struct
  module Path = Hashtbl.Make(H)

  type 'a node= {
    mutable value: 'a option;
    next: 'a node Path.t
  }

  let create value= { value; next= Path.create 0 }

  let append ?(value=None) node key=
    match Path.find node.next key with
    | child-> child
    | exception Not_found->
        let child= create value in
        Path.replace node.next key child;
        child

  let rec set node path value=
    match path with
    | []-> node.value <- Some value
    | hd::tl-> match Path.find node.next hd with
      | child-> set child tl value
      | exception Not_found-> set (append node hd) tl value

  let rec get node path=
    match path with
    | []-> node.value
    | hd::tl-> match Path.find node.next hd with
      | child-> get child tl
      | exception Not_found-> None

  let unset node path=
    let rec unset node path=
      match path with
      | []-> node.value <- None; true
      | hd::tl-> match Path.find node.next hd with
        | child->
          if unset child tl then
            if Path.length child.next = 0 && child.value = None
            then (Path.remove node.next hd; true)
            else false
          else false
        | exception Not_found-> false
    in unset node path |> ignore

  let rec sub node path=
    match path with
    | []-> Some node
    | hd::tl-> match Path.find node.next hd with
      | child-> sub child tl
      | exception Not_found-> None
end

