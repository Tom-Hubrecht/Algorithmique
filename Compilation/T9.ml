(* Mode T9 *)

type trie = { words: string list; branches: (int * trie) list}

let empty = { words = []; branches=[] }

let rec find t l = match l with
  | []   -> failwith "Empty list"
  | [x]  -> (try (List.assoc x t.branches).words with Not_found -> [])
  | x::q -> find (try (List.assoc x t.branches) with Not_found -> empty) q

let rec change_assoc a b = function
  | [] -> [a,b]
  | (c,d)::q -> if c = a then
                  (a,b)::q
                else
                  (c,d)::(change_assoc a b q)

let branch x t = try (List.assoc x t.branches) with Not_found -> empty

let add t l s =
  let rec aux_add t = function
    | [] -> if List.mem s t.words then
              t
            else
              {words = s::t.words; branches = t.branches}
    | x::q -> {words = t.words;
                branches = (change_assoc x (aux_add (branch x t) q) t.branches)}
  in
  aux_add t l

let key c = match c with
  | 'a' | 'b' | 'c'       -> 2
  | 'd' | 'e' | 'f'       -> 3
  | 'g' | 'h' | 'i'       -> 4
  | 'j' | 'k' | 'l'       -> 5
  | 'm' | 'n' | 'o'       -> 6
  | 'p' | 'q' | 'r' | 's' -> 7
  | 't' | 'u' | 'v'       -> 8
  | 'w' | 'x' | 'y' | 'z' -> 9
  | _ -> 0

let intlist_of_string s =
  let n = String.length s in
  let l = ref [] in
  for i = (n - 1) downto 0 do
    l := (key s.[i])::!l;
  done;
  !l

let add_word t s = add t (intlist_of_string s) s

let dict = [
  "lex"; "key"; "void" ; "caml" ; "unix" ; "for" ; "while" ; "done" ;
  "let" ; "fold"; "val"; "exn" ; "rec" ; "else" ; "then" ; "type" ;
  "try" ; "with" ; "to"; "find" ; "do" ; "in" ; "if" ; "hd" ; "tl" ;
  "iter" ; "map" ; "get"; "copy" ; "and"; "as" ; "begin" ; "class" ;
  "downto" ; "end" ; "exception" ; "false" ; "fun" ; "function" ;
  "match" ; "mod" ; "mutable" ; "open" ; "or" ; "true" ; "when" ;
  "load" ; "mem" ; "length" ; "bash" ; "unit" ; "site"; "php"; "sql";
  "ssh"; "spam"; "su"; "qt"; "root"; "bsd"; "boot"; "caml"; "bash";
  "ocaml"; "kde"; "gtk" ; "gcc"
]

let t = (List.fold_left add_word empty dict)

let () = assert (find t [2;2;6;5] = ["caml"])
let () = assert (let l = find t [4;3] in l = ["hd"; "if"] || l = ["if"; "hd"])
let () = assert (find t [4;3;8]   = ["get"])
let () = assert (find t [8;6;4;3] = ["void"])
let () = assert (find t [8;6;4;8] = ["unit"])

let rec del x = function
  | [] -> raise Not_found
  | a::q when x = a -> q
  | a::q -> a::(del x q)

let remove_word t s =
  let l = intlist_of_string s in
  let rec aux_rem t = function
    | [] -> {t with words = (del s t.words)}
    | x::q -> {t with branches = change_assoc x (aux_rem (branch x t) q) t.branches}
  in
  aux_rem t l

let t = remove_word t "caml"
let () = assert (find t [2;2;6;5] = [])
let () = assert (let l = find t [4;3] in l = ["hd"; "if"] || l = ["if"; "hd"])
let () = assert (find t [4;3;8]   = ["get"])
