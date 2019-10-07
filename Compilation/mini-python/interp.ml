
open Ast
open Format

(* Exception levée pour signaler une erreur pendant l'interprétation *)
exception Error of string
let error s = raise (Error s)

(* Les valeurs de Mini-Python

   - une différence notable avec Python : on
     utilise ici le type int alors que les entiers de Python sont de
     précision arbitraire ; on pourrait utiliser le module Big_int d'OCaml
     mais on choisit ici la facilité
   - ce que Python appelle une liste est en réalité un tableau
     redimensionnable ; dans le fragment considéré ici, il n'y a pas
     de possibilité d'en modifier la longueur, donc un simple tableau OCaml
     convient *)
type value =
  | Vnone
  | Vbool of bool
  | Vint of int
  | Vstring of string
  | Vlist of value array

(* Affichage d'une valeur sur la sortie standard *)
let rec print_value = function
  | Vnone -> printf "None"
  | Vbool true -> printf "True"
  | Vbool false -> printf "False"
  | Vint n -> printf "%d" n
  | Vstring s -> printf "%s" s
  | Vlist a ->
    let n = Array.length a in
    printf "[";
    for i = 0 to n-1 do print_value a.(i); if i < n-1 then printf ", " done;
    printf "]"

(* Interprétation booléenne d'une valeur

   En Python, toute valeur peut être utilisée comme un booléen : None,
   la liste vide, la chaîne vide et l'entier 0 sont considérés comme
   False et toute autre valeurs comme True *)

let is_false = function
  | Vnone | Vbool false | Vint 0 | Vlist [| |] | Vstring "" -> true
  | _ -> false

let is_true v = not (is_false v)

let rec compare_value = function
  | Vnone, Vnone -> 0
  | Vint x, Vint y -> x - y
  | Vint x, Vbool b -> if b then (x - 1) else x
  | Vbool b, Vint x -> if b then (1 - x) else -x
  | Vbool true, Vbool false -> 1
  | Vbool false, Vbool true -> -1
  | Vbool _, Vbool _ -> 0
  | Vlist l1, Vlist l2 ->
      begin
        let b = ref 0 and i = ref 0 in
        while (!b = 0) && !i < (min (Array.length l1) (Array.length l2)) do
          b := (compare_value (l1.(!i), l2.(!i)));
          i := !i + 1;
        done;
        if !b = 0 then (Array.length l1) - (Array.length l2) else !b
      end
  | Vstring s1, Vstring s2 ->
      begin                                                                       
        let b = ref 0 and i = ref 0 in                                            
        while (!b = 0) && !i < (min (String.length s1) (String.length s2)) do       
          if s1.[!i] < s2.[!i] then b := -1;
          if s1.[!i] > s2.[!i] then b := 1;
          i := !i + 1;                                                            
        done;                                                                     
        if !b = 0 then (String.length s1) - (String.length s2) else !b              
      end
  | _ -> error "unsupported operand types"

(* Les fonctions sont ici uniquement globales *)

let functions = (Hashtbl.create 16 : (string, ident list * stmt) Hashtbl.t)

(* L'instruction 'return' de Python est interprétée à l'aide d'une exception *)

exception Return of value

(* Les variables locales (paramètres de fonctions et variables introduites
   par des affectations) sont stockées dans une table de hachage passée en
   arguments aux fonctions suivantes sous le nom 'ctx' *)

type ctx = (string, value) Hashtbl.t

(* Interprétation d'une expression (renvoie une valeur) *)

let rec expr ctx = function
  | Ecst Cnone ->
      Vnone
  | Ecst (Cstring s) ->
      Vstring s
  (* arithmétique *)
  | Ecst (Cint n) ->
      Vint n
  | Ebinop (Badd | Bsub | Bmul | Bdiv | Bmod |
            Beq | Bneq | Blt | Ble | Bgt | Bge as op, e1, e2) ->
      let v1 = expr ctx e1 in
      let v2 = expr ctx e2 in
      begin match op, v1, v2 with
        | Badd, Vint n1, Vint n2 -> Vint (n1 + n2)
        | Bsub, Vint n1, Vint n2 -> Vint (n1 - n2)
        | Bmul, Vint n1, Vint n2 -> Vint (n1 * n2)
        | Bdiv, Vint n1, Vint n2 -> if n2 = 0 then
                                        error "Division par 0"
                                    else
                                        Vint (n1 / n2)
        | Bmod, Vint n1, Vint n2 -> if n2 = 0 then
                                        error "Module par 0"
                                    else
                                        Vint (n1 mod n2)
        | Beq, _, _  -> Vbool (v1 = v2)
        | Bneq, _, _ -> Vbool (v1 <> v2)
        | Blt, _, _  -> Vbool (compare_value (v1, v2) < 0)
        | Ble, _, _  -> Vbool (compare_value (v1, v2) <= 0)
        | Bgt, _, _  -> Vbool (compare_value (v1, v2) > 0)
        | Bge, _, _  -> Vbool (compare_value (v1, v2) >= 0)
        | Badd, Vstring s1, Vstring s2 ->
            Vstring (s1 ^ s2)
        | Badd, Vlist l1, Vlist l2 ->
            Vlist (Array.append l1 l2)
        | _ -> error "unsupported operand types"
      end
  | Eunop (Uneg, e1) ->
      begin
          match expr ctx e1 with
              | Vint x -> Vint (-x)
              | Vbool true -> Vint (-1)
              | Vbool false -> Vint 0
              | _ -> error "unsupported operand type"
      end
  (* booléens *)
  | Ecst (Cbool b) ->
      Vbool b
  | Ebinop (Band, e1, e2) ->
      Vbool ((is_true (expr ctx e1)) && (is_true (expr ctx e2)))
  | Ebinop (Bor, e1, e2) ->
      Vbool ((is_true (expr ctx e1)) || (is_true (expr ctx e2)))
  | Eunop (Unot, e1) ->
      Vbool (is_false (expr ctx e1))
  | Eident id ->
      begin
        try Hashtbl.find ctx id with Not_found -> error "unassigned variable"
      end
  (* appel de fonction *)
  | Ecall ("len", [e1]) ->
      begin
        match (expr ctx e1) with
          | Vlist l -> Vint (Array.length l)
          | _ -> error "unsupported operand type"
      end
  | Ecall ("list", [Ecall ("range", [e1])]) ->
      begin
        match (expr ctx e1) with
          | Vint n ->
              let l = Array.make n (Vint 0) in
              for i = 1 to (n - 1) do
                l.(i) <- Vint i;
              done;
            Vlist l
          | _ -> error "unsupported operand type"
      end
  | Ecall (f, el) ->
      begin
      try let pl, b = (Hashtbl.find functions f) in
        let env = (Hashtbl.create 16) in
        List.iter2 (fun x e -> Hashtbl.add env x (expr ctx e)) pl el;
        stmt env b;
        Vnone
        with
          | Not_found -> error "undefined function"
          | Invalid_argument _ -> error "incorrect number of arguments"
          | Return v -> v
      end
  | Elist el ->
      Vlist (Array.of_list (List.map (fun e -> expr ctx e) el))
  | Eget (e1, e2) ->
      begin
        match (expr ctx e1), (expr ctx e2) with
          | Vlist l, Vint i -> if i < (Array.length l) then
                                 l.(i)
                               else
                                 error "index error"
          | _, _ -> error "unsupported operand types"
      end

(* interprétation d'une instruction ; ne renvoie rien *)

and stmt ctx = function
  | Seval e ->
      ignore (expr ctx e)
  | Sprint e ->
      print_value (expr ctx e); printf "@."
  | Sblock bl ->
      block ctx bl
  | Sif (e, s1, s2) ->
      if (is_true (expr ctx e)) then
        stmt ctx s1
      else
        stmt ctx s2
  | Sassign (id, e1) ->
      Hashtbl.replace ctx id (expr ctx e1)
  | Sreturn e ->
      raise (Return (expr ctx e))
  | Sfor (x, e, s) ->
      begin
        match (expr ctx e) with
          | Vlist l ->
              for i = 0 to ((Array.length l) - 1) do
                Hashtbl.replace ctx x l.(i);
                stmt ctx s;
              done;
          | _ -> error "unsupported operand type"
      end
  | Sset (e1, e2, e3) ->
      begin
        match (expr ctx e1), (expr ctx e2) with
          | Vlist l, Vint i -> l.(i) <- (expr ctx e3)
          | _, _ -> error "unsupported operand types"
      end

(* interprétation d'un bloc i.e. d'une séquence d'instructions *)

and block ctx = function
  | [] -> ()
  | s :: sl -> stmt ctx s; block ctx sl

(* interprétation d'un fichier
   - dl est une liste de définitions de fonction (cf Ast.def)
   - s est une instruction, qui représente les instructions globales
 *)

let file (fl, s) =
  List.iter (fun (f, p, b) -> Hashtbl.replace functions f (p, b)) fl;
  stmt (Hashtbl.create 16) s



