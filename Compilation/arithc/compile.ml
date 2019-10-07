
(* Production de code pour le langage Arith *)

open Format
open X86_64
open Ast

(* Exception à lever quand une variable (locale ou globale) est mal utilisée *)
exception VarUndef of string

(* Taille de la frame, en octets (chaque variable locale occupe 8 octets) *)
let frame_size = ref 0

(* Les variables globales sont stockées dans une table de hachage *)
let (genv : (string, unit) Hashtbl.t) = Hashtbl.create 17

(* On utilise une table d'association dont les clés sont les variables locales
   (des chaînes de caractères) et où la valeur associée est la position
   par rapport à %rbp (en octets) *)
module StrMap = Map.Make(String)

(* Compilation d'une expression *)
let compile_expr =
  (* Fonction récursive locale à compile_expr utilisée pour générer le code
     machine de l'arbre de syntaxe abstraite associé à une valeur de type
     Ast.expr ; à l'issue de l'exécution de ce code, la valeur doit se trouver
     en sommet de pile *)
  let rec comprec env next = function
    | Cst i ->
        pushq (imm i)
    | Var x ->
        pushq (lab x)
    | Binop (o, e1, e2)->
        begin
          let c = (comprec env next e1) ++ (comprec env next e2) in
          match o with
            | Add ->
                c ++
                popq rax ++
                popq rbx ++
                addq !%rbx !%rax ++
                pushq !%rax
            | Sub ->
                c ++
                popq rbx ++
                popq rax ++
                subq !%rbx !%rax ++
                pushq !%rax
            | Mul ->
                c ++
                popq rbx ++
                popq rax ++
                imulq !%rbx !%rax ++
                pushq !%rax
            | Div ->
                c ++
                popq rbx ++
                popq rax ++
                movq (imm 0) !%rdx ++
                idivq !%rbx ++
                pushq !%rax
        end
    | Letin (x, e1, e2) ->
        if !frame_size = next then frame_size := 8 + !frame_size;
        nop (* À COMPLÉTER *)
  in
  comprec StrMap.empty 0

(* Compilation d'une instruction *)
let compile_instr = function
  | Set (x, e) ->
      if not (Hashtbl.mem genv x) then Hashtbl.add genv x ();
      (compile_expr e) ++
      popq rax ++
      movq !%rax (lab x)
  | Print e ->
      (compile_expr e) ++
      popq rdi ++
      call "print_int"

(* Compile le programme p et enregistre le code dans le fichier ofile *)
let compile_program p ofile =
  let code = List.map compile_instr p in
  let code = List.fold_right (++) code nop in
  let p =
    { text =
        globl "main" ++ label "main" ++
        nop (* À COMPLÉTER *) ++
        code ++
        ret ++
        label "print_int" ++
        movq !%rdi !%rsi ++
        leaq (lab ".Sprint_int") rdi ++
        movq (imm 0) !%rax ++
        call "printf" ++
        ret;
      data =
        Hashtbl.fold (fun x _ l -> label x ++ dquad [1] ++ l) genv
          (label ".Sprint_int" ++ string "%d\n")
    }
  in
  let f = open_out ofile in
  let fmt = formatter_of_out_channel f in
  X86_64.print_program fmt p;
  (* on "flush" le buffer afin de s'assurer que tout y a été écrit
     avant de le fermer *)
  fprintf fmt "@?";
  close_out f
