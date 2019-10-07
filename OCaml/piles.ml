(* Implémentation à l'aide de listes *)
let est_vide_l p =
  p == []
;;

let empile_l p x =
  x::p
;;

let depile_l p = match p with
  | [] -> failwith "Pile vide"
  | t::q -> t
;;