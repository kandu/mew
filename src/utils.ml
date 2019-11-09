module Queue = struct
  let rec drop n q=
    if n > 0 then
      (ignore (Queue.take q);
      drop (n-1) q)

  let to_list_rev q= Queue.fold (fun l key-> key::l) [] q
  let to_list q= q |> to_list_rev |> List.rev
end

