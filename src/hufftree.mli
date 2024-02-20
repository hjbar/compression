(** definition du type 'a tree qui correspond a un arbre binaire value aux
    feuilles par des valeurs de types a. Empty si l'arbre ne contient aucun
    element. *)
type 'a tree =
  | Empty
  | Leaf of 'a
  | Node of 'a tree * 'a tree

(** [print_tree t]Fonction de test permettant d'afficher de gauche à droite le
    contenu d'un arbre value au feuilles par des caracteres affichage :
    char:caractere à une feuille, prof: profondeur de la feuille, code: code de
    huffman*)
val print_tree : char tree -> unit

(** [compare_huffheap p1 p2] Fonction permettant de comparer des tuples en
    fonction de leur premier element. Renvoie 1 lorsque le premier element de
    [p1] est superieur a celui de [p2]. -1 s'il est inferieur et 0 s'ils sont
    egaux.*)
val compare_huffheap : 'a * 'b -> 'a * 'c -> int

(** [bigger_huffheap p1 p2] utilisee avec les fonction du module heap pour
    comparer des tuples d'entier et d'arbre. La fonction Renvoie un booleen Frue
    lorsque [compare_huffheap p1 p2] renvoie 1, False sinon*)
val bigger_huffheap : 'a * 'b -> 'a * 'c -> bool
