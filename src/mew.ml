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

  module Key = Modal.Key
  module Mode = Modal.Mode
  module MsgBox = Concurrent.MsgBox
  module Thread = Concurrent.Thread

  let (>>=)= Thread.bind

  class edit state= object(self)
    val i= MsgBox.create ()
    val o: Key.t MsgBox.t= MsgBox.create ()
    val mutable curr_mode: Mode.t= let _, mode= state#default_mode in mode
    method keyin (key:Key.t)= MsgBox.put i key

    method i= i
    method o= o

    method getMode= curr_mode
    method setMode mode= curr_mode <- Mode.Modes.find mode state#modes
    method timeout= match Mode.timeout self#getMode with
      | Some timeout-> timeout
      | None-> state#timeout
    method bindings= Mode.bindings self#getMode

    initializer
      (*
      let curr_node= ref curr_mode.bindings in
      let key_queue= Queue.create () in
      let reset ()= curr_node:= curr_mode.bindings in
      let build_keySeq key_seq=
        let async key= Thread.async
          (fun ()-> MsgBox.put i (Mode.Key key)) in
        List.iter async key_seq in
      let create_trigger action ()=
        let notify= MsgBox.create () in
        let waiting ()=
          MsgBox.get notify >>= function
          | true-> 
          | false-> Thread.return ()
        in
        Thread.async waiting;
        notify
      in
      let listen ()=
        MsgBox.get i >>= fun action->
        match action with
        | Mode.Switch name-> self#setMode name; Thread.return ()
        | Key key-> (match Mode.KeyTrie.sub !curr_node [key] with
          | Some node-> Thread.return ()
          | None-> MsgBox.put o key)
        | KeySeq keq_seq-> build_keySeq keq_seq; Thread.return ()
        | Custom f-> f (); Thread.return ()
      in
      Thread.async listen
         *)
      (*let extract_action node=
        let mem_key= Queue.copy mem_key in
        let key_list= mem_key 
          |> Queue.fold (fun l key-> key::l) []
          |> List.rev
        in
        let rec extract_action 
        (fun acc key->
          acc)
          []
          mem_key
      in*)
      (*
      let output_seq o seq=
        let rec output_seq ()=
          match Queue.take seq with
          | key-> MsgBox.put o key >>= output_seq
          | exception Queue.Empty-> Thread.return ()
        in
        output_seq ()
      in
      let rec listen ()=
        MsgBox.get i >>= fun key->
        match Mode.KeyTrie.sub (Mode.bindings self#getMode) [key] with
        | Some node->
          if Mode.KeyTrie.is_leaf node then
            match Mode.KeyTrie.get node [] with
            | Some action-> (match action with
              | Switch name-> self#setMode name; listen ()
              | Key key-> MsgBox.put o key >>= listen
              | KeySeq keyseq-> ignore keyseq; listen ()
              | Custom f-> f (); listen ()
              )
            | None-> MsgBox.put o key >>= listen
          else
            let mem_key= Queue.create () in
            Queue.add key mem_key;
            forward mem_key node
        | None-> MsgBox.put o key >>= listen
      and forward mem_key node=
        Thread.pick
          [ (MsgBox.get i >>= fun key-> Thread.return (Some key));
            (Thread.sleep self#timeout >>= fun ()-> Thread.return None)]
        >>= function
        | Some key->
          Queue.add key mem_key;
          (match Mode.KeyTrie.sub node [key] with
          | Some node->
            if Mode.KeyTrie.is_leaf node then
              match Mode.KeyTrie.get node [] with
              | Some action-> ignore action; Thread.return ()
              | None-> (); Thread.return ()
            else
              forward mem_key node
          | None-> Thread.return ());
        | None-> Thread.return ()
      and keyin_seq last keyseq mem_key node=
        match Queue.take keyseq with
        | key->
          (match Mode.KeyTrie.sub (Mode.bindings self#getMode) [key] with
          | Some node->
            if Mode.KeyTrie.is_leaf node then
              match Mode.KeyTrie.get node [] with
              | Some action-> (match action with
                | Switch name-> self#setMode name; listen ()
                | Key key-> MsgBox.put o key >>= listen
                | KeySeq keyseq-> ignore keyseq; listen ()
                | Custom f-> f (); listen ()
                )
              | None-> MsgBox.put o key >>= listen
            else
              let mem_key= Queue.create () in
              Queue.add key mem_key;
              forward mem_key node
          | None-> MsgBox.put o key >>= listen)
        | exception Queue.Empty->
          let keys=
            match last with
            | Some (action, key_seq)-> action (); key_seq
            | None-> mem_key
          in
          output_seq o keys >>= listen
      in
      Thread.async listen
      *)
      let rec get_key sources=
        match sources with
        | []-> MsgBox.get i >>= fun key-> Thread.return (key, sources)
        | source::tl->
          match Queue.take source with
          | key-> Thread.return (key, sources)
          | exception Queue.Empty-> get_key tl
      in
      let output_seq o seq=
        let rec output_seq ()=
          match Queue.take seq with
          | key-> MsgBox.put o key >>= output_seq
          | exception Queue.Empty-> Thread.return ()
        in
        output_seq ()
      in
      let perform action sources=
        match action with
        | Mode.Switch name-> self#setMode name;
          sources
        | Key key->
          let seq= Queue.create() in
          Queue.add key seq;
          seq::sources
        | KeySeq keyseq-> keyseq::sources
        | Custom f-> f (); sources
      in
      let rec listen sources mem_key last node=
        match node with
        | Some node->
          Thread.pick
            [ (Thread.sleep self#timeout >>=
                fun ()-> Thread.return None);
              get_key sources >>= fun (key, sources)->
                Thread.return (Some (key, sources))
              ]
          >>= (function
            | Some (key, sources)->
              try_matching sources mem_key last node key
            | None-> skip_matching sources mem_key last)
        | None-> let node= self#bindings in
          get_key sources >>= fun (key, sources)->
          Queue.add key mem_key;
          try_matching sources mem_key last node key
      and try_matching sources mem_key last node key=
        match Mode.KeyTrie.sub node [key] with
        | Some node->
          let last=
            match Mode.KeyTrie.get node [] with
            | Some action->
              Some (Queue.copy mem_key, action)
            | None-> last
          in
          listen sources mem_key last (Some node)
        | None->
          skip_matching sources mem_key last
      and skip_matching sources mem_key last=
        match last with
        | Some (seq, action)->
          Utils.Queue.drop (Queue.length seq) mem_key;
          let sources= perform action sources in
          listen (mem_key::sources) (Queue.create ()) None None
        | None->
          output_seq o mem_key >>= fun ()->
          listen sources (Queue.create()) None None
      in
      Thread.async (fun ()-> listen [] (Queue.create ()) None None)
  end

  class state modes= object(self)
    val mutable timeout= 1.
    val mutable default_mode= Modal.Mode.default_mode modes

    method edit= new edit self
    method modes= modes
    method default_mode= default_mode
    method timeout= timeout
  end
end

