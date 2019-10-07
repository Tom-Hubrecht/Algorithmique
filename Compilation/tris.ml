(* Tri par insertion *)

let rec insertion x l = match l with
  | [] -> [x]
  | t::q -> if t < x then
              t::(insertion x q)
            else
              x::l


let rec insertion_sort l = match l with
  | [] | [_] -> l
  | t::q -> insertion t (insertion_sort q)


(* Tri fusion *)

let split l =
  let rec aux_split l l1 l2 = match l with
    | [] -> l1, l2
    | t::q -> aux_split q l2 (t::l1)
  in
  aux_split l [] []


let rec fusion l1 l2 = match l1, l2 with
  | [],_ -> l2
  | _, [] -> l1
  | t1::q1, t2::q2 -> if t1 < t2 then
                        t1::(fusion q1 l2)
                      else
                        t2::(fusion q2 l1)


let rec mergesort = function
  | [] -> []
  | [x] -> [x]
  | l -> let l1, l2 = split l in
         fusion (mergesort l1) (mergesort l2)


(* Tri rapide *)

let partition x l =
  let rec aux_part x l l1 l2 = match l with
    | [] -> l1, l2
    | t::q -> if t < x then
                aux_part x q (t::l1) l2
              else
                aux_part x q l1 (t::l2)
  in
  aux_part x l [] []


let rec quicksort l = match l with
  | [] | [_] -> l
  | t::q -> let l1, l2 = partition t q in
            (quicksort l1)@(t::(quicksort l2))


(* Tris par tas *)

type 'a heap = Null | Fork of 'a * 'a heap * 'a heap
exception Empty_heap

let rec merge a b = match a,b with
  | Null, _ -> b
  | _, Null -> a
  | Fork(a_x, a_l, a_r), Fork(b_x, b_l, b_r) -> if a_x < b_x then
                                                  Fork(a_x, a_r, merge a_l b)
                                                else
                                                  Fork(b_x, b_r, merge b_l a)


let add_heap x h =
  merge (Fork(x, Null, Null)) h


let extract_min = function
  | Null -> raise Empty_heap
  | Fork(x, l, r) -> x, (merge l r)


let heap_of_list l =
  let rec aux_hol h = function
    | [] -> h
    | t::q -> aux_hol (add_heap t h) q
  in
  aux_hol Null l


let list_of_heap h =
  let rec aux_loh l = function
    | Null -> l
    | h -> let x, n_h = extract_min h in
           aux_loh (x::l) n_h
    in
    List.rev (aux_loh [] h)


let heapsort l =
  list_of_heap (heap_of_list l)


(* Tests tri *)

let rec print_heap fmt = function
  | Null -> Format.fprintf fmt "Null"
  | Fork (x, a, b) ->
      Format.fprintf fmt "Fork (@[%d,@ %a,@ %a@])"
        x print_heap a print_heap b

let rec is_heap_rec min = function
  | Null -> true
  | Fork (x, l, r) -> min <= x && is_heap_rec x l && is_heap_rec x r

let is_heap = is_heap_rec min_int

let check_heap h =
  let ok = is_heap h in
  Format.printf "%a: %s@."
    print_heap h (if ok then "OK" else "FAILED");
  if not ok then exit 1

let () =
  let h1 = add_heap 2 (add_heap 1 (add_heap 3 Null)) in
  check_heap h1;
  let h2 = add_heap 4 (add_heap 0 (add_heap 1 Null)) in
  check_heap h2;
  let h = merge h1 h2 in
  check_heap h;
  let m, h = extract_min h in
  assert (m = 0);
  check_heap h

let rec print fmt = function
 | [] -> ()
 | [x] -> Format.fprintf fmt "%d" x
 | x :: l -> Format.fprintf fmt "%d, %a" x print l

let rec is_sorted = function
 | [] | [_] -> true
 | x :: (y :: _ as l) -> x <= y && is_sorted l

let check l =
 let r = heapsort l in
 let ok = is_sorted r in
 Format.printf "[%a] => [%a]: %s@."
   print l print r (if ok then "OK" else "FAILED");
 if not ok then exit 1

let () =
 check [1; 2; 3];
 check [3; 2; 1];
 check [];
 check [1];
 check [2; 1; 1]