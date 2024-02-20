type 'a tree =
  | Empty
  | Leaf of 'a
  | Node of 'a tree * 'a tree

let print_tree t =
  let rec print_tree_bis t prof code =
    match t with
    | Empty -> Printf.printf ""
    | Leaf c -> Printf.printf "char:%c prof:%d code:%d\n" c prof code
    | Node (l, r) ->
      print_tree_bis l (prof + 1) (code * 2);
      print_tree_bis r (prof + 1) ((code * 2) + 1)
  in
  print_tree_bis t 0 0;
  Printf.printf "\n"

let compare_huffheap p1 p2 = compare (fst p1) (fst p2)

let bigger_huffheap p1 p2 = compare_huffheap p1 p2 > 0
