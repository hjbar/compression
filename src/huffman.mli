open Hufftree
open Heap
open Bs

(** [char_freq in_c] renvoie un array de taille 256 contenant la frequence
    d'apparition dans le fichier associe à la variable de type in_channel [in_c]
    de tous les caracteres figurant dans la norme ascii. Le i-eme element
    correspond à la frequence d'apparition du caractere de code ascii i*)
val char_freq : in_channel -> int array

(** [file_to_heap in_c] renvoie un tas dont les elements sont des tuples. Le
    second element des tuples sont de type Leaf (char tree) contenant un
    caractere. Le premier element des tuples correspond au nombre d'occurence du
    caractere stocke dans l'arbre du tuple dans le fichier associe a la variable
    de type in_channel [in_c]. *)
val file_to_heap : in_channel -> (int * char tree) heap

(** [heap_to_tree h] transforme le tas [h] dont les elements sont des tuples
    d'entier et d'arbre de type generique en un arbre de huffman ou les elements
    dont les entiers à l'interieur du tuple sont plus grand sont en general en
    general au profondeur faible.*)
val heap_to_tree : (int * 'a tree) heap -> 'a tree

(** [huff_tab huffman_tree] transforme l'arbre de char [huffman_tree] en un
    array de tuple d'entier. Le i-eme element de l'array est associe au
    caractere de code ascii i. On y stocke dans la profondeur (par rapport à la
    racine) à laquelle se trouve ce caractere dans l'arbre et le code que l'on
    utilisera dans le fichier compresse en base 10 associe au caractere. On lit
    l'arbre de gauche à droite. On multuplie le code courrant par 2 lorsque l'on
    accede au descendant gauche. On multiplie le code courrant par 2 et on y
    ajoute 1 lorsque l'on accede au descendant de droite.*)
val huff_tab : char tree -> (int * int) array

(** [write_huffcode tab os] ecrit la longueur du code en base 2 (sur 3 bits)
    (profondeur dans l'arbre) et les codes des caracteres de l'arbre de huffman
    (sur 'longueur du code' bits) dans le fichier associé à la variable ostream
    [os]. [tab] s'agit d'un tableau obtenu à partir de la fonction
    [huff_tab huffman_tree]. Pour les caractères ne faisant par parti de l'abre
    de huffman, on ecrit que la longueur de leur code est de 1 bit et leur code
    est 0. Renvoie le nombre de bits ecrit dans le fichier. *)
val write_huffcode : (int * int) array -> ostream -> int

(** [write_code os long code] ecrit dans le fichier le code d'un caractere en
    base 2. [os] est une variable ostream grace à laquelle on peut ecrire dans
    le fichier. [long] correspond au nombre de bit que l'on doit ecrire [code]
    en un entier en base 10 que l'on ecrit en base 2 dans le fichier*)
val write_code : ostream -> int -> int -> unit

(** [write_compress tab in_c os] lit tous les caracteres du fichier associe a la
    variable de type in_channel [in_c] et pour chaque caractere ecrit le code
    contenu dans l'array [tab] dans le fichier associe a la variable de type
    ostream [os]. Renvoie les nombre de bits dans le fichier associe à [in_c] et
    le nombre de bit ecrit au cours de l'execution de la fonction*)
val write_compress : (int * int) array -> in_channel -> ostream -> int * int

(** [print_file_size n] fonction affichant la taille [n] en o puis après
    conversion en Ko, Mo, Go et To.*)
val print_file_size : int -> unit

(** [compress f stats] compresse le fichier dont le nom est la chaîne de
    caractère passé en ligne de commande [f]. Le format du fichier compressé est
    une serie de 0 et de 1. Lorsque l'argument booléen [stats] est vrai on
    affiche la taille du fichier avant_compression et après*)
val compress : string -> bool -> unit

(** Definition de type data_decompress utilise les donnees extraites des
    premiers caracteres du fichier compresse: long : int representant nombre de
    bits d'un code de huffman en base 2 code : int code de huffman en base 10 'a
    tree : arbre de huffman value aux feuilles par des valeurs de types 'a. *)
type 'a data_decompress

(** [extr_data is i list] lit les premiers caracteres du fichier compresse
    associé à la variable istream [is] qui nous donnent les informations pour
    dechiffrer le reste du fichier. La fonction renvoie ces données dans une
    liste de type data_decompress *)
val extr_data : istream -> char data_decompress list

(** [ajoute_triee list elem] Fonction auxiliaire de [merge_2_elem] qui prend en
    argument une liste de type data_decompress [list] qui a la propriete d'etre
    trie en fonction du champ long (=>longueur des codes) des elements de la
    liste. La fonction va inserer [elem] dans la liste de tel sorte à ce que
    [list] soit toujours trie.*)
val ajoute_triee :
  'a data_decompress list -> 'a data_decompress -> 'a data_decompress list

(** [merge_2_elem list elem] Fonction auxiliaire de [recreate_tree] qui prend en
    argument une liste de type data_decompress [list] et va rechercher un
    element avec la meme longueur et le meme code en base 2 a la seul difference
    du dernier bit que [elem]. Une fois que l'on a trouve cet element, il est
    retire de la liste et on ajoute un nouvel element dont la longueur est
    decremente de 1, le code est divise par 2(supprime le dernier bit) et leur
    arbre sont regroupes.*)
val merge_2_elem :
  'a data_decompress list -> 'a data_decompress -> 'a data_decompress list

(** [recreate_tree list] Sur-fonction de [merge_2_elem] qui prend le premier
    element et appelle [merge_2_elem] on fait cela jusqu'à ce que la liste soit
    de taille 1. Apres quoi, on renvouie le champ 'tree' de l'element restant.
    L'arbre obtenu correspond a l'abre de huffman contruit avant la compression
    du fichier que l'on decompresse*)
val recreate_tree : 'a data_decompress list -> 'a tree

(** [decomp_file is out_c tree] va ecrire dans le fichier associé la variable
    ostream [os] le caractere obtenu a partir du fichier compresse associe a
    [is] et a l'arbre de huffman obtenu apres l'utilisation de l'abre de
    huffman. Leve une exception [Failwith] lorsque l'arbre est vide.
    [Invalid_stream] (leve par [read_bit]) lorsqu'il y a trop de caracteres
    differents dans le fichier et que le code des caracteres dans le fichier
    compresse est trop long. *)
val decomp_file : istream -> out_channel -> char tree -> unit

(** [decompress f] decompresse le fichier compresse passe en ligne de commande
    [f] et cree un nouveau fichier nomme decompressed_[f] (ecrase et remplace le
    fichier s'il existe deja.) *)
val decompress : string -> unit
