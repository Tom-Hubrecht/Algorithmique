(* Ouvrir la fenêtre graphique *)

let _ = Graphics.open_graph " 512x512"

(**************************************)
(* Déclarations des types de l'énoncé *)
(**************************************)

type couleur = Blanc | Noir

type arbre =
  | Feuille of couleur
  | Noeud   of arbre * arbre * arbre * arbre

type image = couleur array array

(**************)
(* Question 1 *)
(**************)

let rec compte_feuilles a = match a with
  | Feuille(_) -> 1
  | Noeud(a1, a2, a3, a4) -> (compte_feuilles a1 + compte_feuilles a2 +
                              compte_feuilles a3 + compte_feuilles a4)


let a =
  Noeud (Noeud (Feuille Blanc,
                Feuille Blanc,
                Feuille Noir,
                Feuille Blanc),
         Feuille Noir,
         Feuille Noir,
         Feuille Noir)

let () = assert (compte_feuilles a = 7)

(**************)
(* Question 2 *)
(**************)

let dessine_arbre k a =
  let rec aux_dessin x_o y_o s = function
    | Feuille(Noir) -> Graphics.fill_rect x_o y_o s s
    | Feuille(Blanc) -> ()
    | Noeud(a1, a2, a3, a4) ->  begin
                                  let n_s = s/2 in
                                  aux_dessin x_o y_o n_s a1;
                                  aux_dessin (x_o + n_s) y_o n_s a2;
                                  aux_dessin x_o (y_o + n_s) n_s a3;
                                  aux_dessin (x_o + n_s) (y_o + n_s) n_s a4;
                                end
  in
  aux_dessin 0 0 k a


let rec simplifie_arbre = function
  | Feuille(_) as f -> f
  | Noeud(a1, a2, a3, a4) ->  let s1 = simplifie_arbre a1 and
                                s2 = simplifie_arbre a2 and
                                s3 = simplifie_arbre a3 and
                                s4 = simplifie_arbre a4 in
                              if s1 = s2 && s2 = s3 && s3 = s4 &&
                                (s1 = Feuille(Blanc) || s1 = Feuille(Noir)) then
                                s1
                              else
                                Noeud(s1, s2, s3, s4)


let image_vers_arbre k img =
  let t = Array.make_matrix k k (Feuille(Blanc)) in
  for i = 0 to (k - 1) do
    for j = 0 to (k - 1) do
      t.(i).(j) <- Feuille(img.(i).(j));
    done;
  done;
  let k' = ref (k / 2) in
  while !k' > 0 do
    for i = 0 to (!k' -1) do
      for j = 0 to (!k' - 1) do
        t.(i).(j) <- Noeud(t.(2*i).(2*j + 1), t.(2*i + 1).(2*j + 1),
                           t.(2*i).(2*j), t.(2*i + 1).(2*j));
      done;
    done;
    k' := !k' / 2;
  done;
  simplifie_arbre t.(0).(0)


(* Test de dessine_arbre *)
let rec q2 a =
  Graphics.clear_graph ();
  dessine_arbre 512 a;
  let rec do_rec () =
    let c = Graphics.read_key () in
    if c = 'q' then ()
    else do_rec ()
  in
  do_rec ()

let () = q2 a

(* Test de image_vers_arbre *)
let img =
[|
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Blanc ;Blanc ;Blanc ;Blanc ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Blanc ;Blanc ;Blanc ;Blanc ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir; Blanc ;Blanc ;Blanc ;Blanc ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir;Blanc ;Blanc ;Blanc ;Blanc ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ;Blanc ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ; |] ;
  [| Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;
     Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ;Noir ; |] ;
  |]


let () = assert (image_vers_arbre (Array.length img) img = a)

(**************)
(* Question 3 *)
(**************)

(* TROIS FONCTIONS A COMPLETER *)
let rec inverse = function
  | Feuille(Blanc) -> Feuille(Noir)
  | Feuille(Noir) -> Feuille(Blanc)
  | Noeud(a1, a2, a3, a4) -> Noeud(inverse a1, inverse a2, inverse a3, inverse a4)


let rec rotate = function
  | Feuille(_) as f -> f
  | Noeud(a1, a2, a3, a4) -> Noeud(rotate a2, rotate a4, rotate a1, rotate a3)


  let rec antirotate = function
  | Feuille(_) as f -> f
  | Noeud(a1, a2, a3, a4) -> Noeud(antirotate a3, antirotate a1,
                                   antirotate a4, antirotate a2)


(* Test des rotations *)
let rec q3 a =
  Graphics.clear_graph ();
  dessine_arbre 512 a;
  let rec do_rec () =
    let c = Graphics.read_key () in
    if c = 'n' then q3 (rotate a)
    else if c = 'p' then q3 (antirotate a)
    else if c = 'i' then q3 (inverse a)
    else if c = 'q' then ()
    else do_rec () in
  do_rec ()

let () = q3 a

(**************)
(* Question 4 *)
(**************)

let rec fractale n =
  if n = 0 then
    Feuille(Noir)
  else
    let a = fractale (n - 1) and f = Feuille(Blanc) in
    Noeud(Noeud(a, a, a, f), Noeud(a, a, f, a),
          Noeud(a, f, a, a), Noeud(f, a, a, a))


let rec q4 i =
  dessine_arbre 512 (fractale i);
  let rec do_rec () =
    let c = Graphics.read_key () in
    if c = 'n' && i < 5 then begin
      Graphics.clear_graph ();
      q4 (i+1)
    end else if c = 'p' && i > 0 then begin
      Graphics.clear_graph ();
      q4 (i-1)
    end else if c = 'q' then
      ()
    else
      do_rec () in
  do_rec ()

let () = q4 0

(**************)
(* Question 5 *)
(**************)

type bit = Zero | Un

let arbre_vers_liste a =
  let l = ref [] in
  let rec aux_avl = function
    | Feuille(Blanc) -> l := Zero::Zero::!l
    | Feuille(Noir) -> l := Zero::Un::!l
    | Noeud(a1, a2, a3, a4) -> (aux_avl a4;
                                aux_avl a3;
                                aux_avl a2;
                                aux_avl a1;
                                l := Un::!l)
  in
  aux_avl a;
  !l


let liste_vers_arbre bits =
  let l = ref bits in
  let rec aux_lva = function
    | Zero::Zero::q -> l := q; Feuille(Blanc)
    | Zero::Un::q -> l := q; Feuille(Noir)
    | Un::q -> l := q;
               let a1 = aux_lva !l in
               let a2 = aux_lva !l in
               let a3 = aux_lva !l in
               let a4 = aux_lva !l in
               Noeud(a1, a2, a3, a4)
    | _ -> failwith "Incorrect structure"
  in
  aux_lva !l


let a = fractale 4

let () = assert (a = liste_vers_arbre (arbre_vers_liste a))

let ecrire_arbre name a =
  () (* À MODIFIER *)

let lire_arbre name =
  Feuille Blanc (* À MODIFIER *)

let q5 a =
  ecrire_arbre "f4.quad" a ;
  let aa = lire_arbre "f4.quad" in
  assert (a = aa)

let () = q5 (fractale 4)

