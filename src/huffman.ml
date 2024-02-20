open Hufftree
open Heap
open Bs

(* Compresser un fichier *)

(* 1ere etape : recuperer le nombre d'occurrences de chaque caractere *)

let char_freq in_c =
  let rec loop in_c tab =
    try
      let o = input_byte in_c in
      tab.(o) <- tab.(o) + 1;
      loop in_c tab
    with End_of_file -> tab
  in
  loop in_c (Array.init 256 (fun _i -> 0))

(* 2eme etape : creer l'arbre d'Huffman a l'aide d'un tas *)

let file_to_heap in_c =
  let tab = char_freq in_c in
  let _i, tas =
    Array.fold_left
      (fun (i, tas) v ->
        let tas =
          if v > 0 then add (v, Leaf (Char.chr i)) tas bigger_huffheap else tas
        in
        (i + 1, tas) )
      (0, empty (0, Empty))
      tab
  in
  tas

let rec heap_to_tree h =
  if heap_size h <= 1 then snd (heap_tas h).(0)
  else
    let min1_l, min1_r = find_min h in
    let h1 = remove_min h bigger_huffheap in
    let min2_l, min2_r = find_min h1 in
    let h2 = remove_min h1 bigger_huffheap in
    let h3 = add (min1_l + min2_l, Node (min2_r, min1_r)) h2 bigger_huffheap in
    heap_to_tree h3

(* 3meme etape : coder les fonctions auxiliaires afin d'ecrire le fichier compresse *)

let huff_tab huffman_tree =
  let rec loop tab tree long val_bit =
    match tree with
    | Empty -> ()
    | Leaf c -> tab.(Char.code c) <- (long, val_bit)
    | Node (l, r) ->
      loop tab l (long + 1) (2 * val_bit);
      loop tab r (long + 1) ((2 * val_bit) + 1)
  in
  let tab = Array.init 256 (fun _i -> (0, 0)) in
  loop tab huffman_tree 0 0;
  tab

let write_huffcode tab os =
  let rec loop tab i os nb_bits =
    if i < 256 then begin
      let long = fst tab.(i) in
      let code = snd tab.(i) in
      write_n_bits os 4 long;
      write_n_bits os long code;
      loop tab (i + 1) os (nb_bits + long + 4)
    end
    else nb_bits
  in
  loop tab 0 os 0

let rec write_code os long code =
  if long > 0 then begin
    write_code os (long - 1) (code / 2);
    write_bit os (code mod 2)
  end

let write_compress tab in_c os =
  let rec loop tab in_c os bits_avant bits_apres =
    try
      let o = input_byte in_c in
      let long = fst tab.(o) in
      let code = snd tab.(o) in
      write_code os long code;
      loop tab in_c os (bits_avant + 8) (bits_apres + long)
    with End_of_file -> (bits_avant, bits_apres)
  in
  loop tab in_c os 0 0

let print_file_size n =
  let rec loop n i =
    if n >= 1000. && i < 4 then loop (n /. 1000.) (i + 1)
    else
      match i with
      | 0 -> Printf.printf "%f o" n
      | 1 -> Printf.printf "%f Ko" n
      | 2 -> Printf.printf "%f Mo" n
      | 3 -> Printf.printf "%f Go" n
      | _ -> Printf.printf "%f To" n
  in
  loop (float_of_int n) 0

(* 4eme etape : ecrire le fichier compresse *)

let compress f stats =
  let in_c = open_in f in
  let h = file_to_heap in_c in
  close_in in_c;

  let tree =
    if heap_size h = 1 then Node (snd (heap_tas h).(0), Empty)
    else heap_to_tree h
  in
  let tab = huff_tab tree in

  let out_c = open_out (f ^ ".hf") in
  let os = of_out_channel out_c in
  let nb_bits_code = write_huffcode tab os in

  let in_c = open_in f in
  let nb_bits_avant, nb_bits_apres = write_compress tab in_c os in

  close_in in_c;
  finalize os;
  close_out out_c;

  if stats then begin
    Printf.printf "Taille de %s : " f;
    print_file_size nb_bits_avant;
    Printf.printf "\n";
    Printf.printf "Taille de %s : " (f ^ ".hf");
    print_file_size (nb_bits_code + nb_bits_apres);
    Printf.printf "\n"
  end

(* Decompresser un fichier *)

type 'a data_decompress =
  { long : int
  ; code : int
  ; tree : 'a tree
  }

(* 1ere etape : recuperer les codes d'Huffman *)

let extr_data is =
  let rec loop is i liste =
    if i < 256 then
      let long = read_n_bits is 4 in
      if long > 0 then
        let code = read_n_bits is long in
        loop is (i + 1) ({ long; code; tree = Leaf (Char.chr i) } :: liste)
        (*On associe le code ASCII au code de l'arbre*)
      else loop is (i + 1) liste
    else List.sort (fun e1 e2 -> compare e2.long e1.long) liste
    (*On range dans l'ordre decroissant de longueur de code hufftree les éléments*)
  in
  loop is 0 []
(*On range dans l'ordre decroissant de longueur de code hufftree les éléments*)

(* 2eme etape : recreer l'arbre d'Huffman *)

let rec ajoute_triee liste elem =
  (*On place l'element avec les elements de meme longueur où les élements de taille inferieur*)
  match liste with
  | [] -> elem :: []
  | frst :: slist ->
    if elem.long < frst.long then frst :: ajoute_triee slist elem
    else elem :: frst :: slist

let rec merge_2_elem liste elem =
  match liste with
  | [] -> elem :: []
  | frst :: slist ->
    if elem.long = frst.long && elem.code / 2 = frst.code / 2 then begin
      if elem.code mod 2 = 0 then
        (*On place le caractere ayant pour dernier caractere de code 0 a gauche*)
        ajoute_triee slist
          { long = elem.long - 1
          ; tree = Node (elem.tree, frst.tree)
          ; code = elem.code / 2
          }
      else
        ajoute_triee slist
          { long = elem.long - 1
          ; tree = Node (frst.tree, elem.tree)
          ; code = elem.code / 2
          }
    end
    else frst :: merge_2_elem slist elem

let rec recreate_tree liste =
  match liste with
  | [] -> Empty
  | elem :: [] -> elem.tree
  (* On renvoie l'arbre quand il n'y a plus qu'un seul element c'est  a dire lorsque l'on a fini de construire l'abre *)
  | elem :: slist ->
    let new_list = merge_2_elem slist elem in
    recreate_tree new_list

(* 3eme etape : coder les fonctions auxiliaires afin d'ecrire le fichier decompresse *)

let decomp_file is out_c orginal_tree =
  let rec loop current_tree =
    match current_tree with
    | Leaf c ->
      Out_channel.output_byte out_c (Char.code c);
      loop orginal_tree
    | Node (l, r) -> (
      try
        let bit = read_bit is in
        if bit = 0 then loop l else loop r
      with
      | End_of_stream -> close_out out_c
      | Invalid_stream ->
        failwith
          "Le programme ne supporte pas les textes avec trop de caracteres \
           differents."
        (*On lit le code compresse bit par bit, read_bit utilise un buffer lorsque ce buffer est de taille supérieur à 8, la fonction
          leve l'exception Invalid_stream.*) )
    | _ -> failwith "ERREUR DANS LA LECTURE DE L'ARBRE DE DECOMPRESSION\n"
  in

  loop orginal_tree

(* 4eme etape : ecrire le fichier decompresse *)

let decompress f =
  let in_c = open_in f in
  let is = of_in_channel in_c in

  let list_data = extr_data is in
  let tree =
    match recreate_tree list_data with
    | Leaf c ->
      Node (Leaf c, Empty)
      (*Le cas où le document n'est ecrit qu'avec un seul caractere*)
    | t -> t
  in
  let out_c = open_out ("decompressed_" ^ Filename.remove_extension f) in
  decomp_file is out_c tree;
  close_in in_c
