type 'a heap

(** The type of heaps. Elements are ordered using generic comparison. (** The
    type of heaps. Elements are ordered using generic comparison. Les elements
    sont stockés à l'interieur d'un array dans le champ tas. Et on utilise un
    champ size pour indiquer les elements qui appartiennent au tas, les elements
    au dela de size n'appartiennent pas au tas (i.e tableau dynamique)*) *)

(** [empty] is the empty heap. *)
val empty : 'a -> 'a heap

(** [add e h] add element [e] to [h]. Lorsque l'on ajoute un element on
    increment de 1 le champ et lorsque le champ size est superieur ou egal a la
    taille de l'array du champ tas alors on double la taille de l'array.*)
val add : 'a -> 'a heap -> ('a -> 'a -> bool) -> 'a heap

(** [find_min h] returns the smallest elements of [h] w.r.t to the generic
    comparison [<] *)
val find_min : 'a heap -> 'a

(** [remove_min h] returns [h] where the smallest elements of [h] w.r.t to the
    generic comparison [<] element has been removed. On divise par deux le champ
    size du tas lorsque Array.length([h].tas) / 4 > [h].size *)
val remove_min : 'a heap -> ('a -> 'a -> bool) -> 'a heap

(** [is_singleton h] returns [true] if [h] contains one element *)
val is_singleton : 'a heap -> bool

(** [is_empty h] returns [true] if [h] contains zero element *)
val is_empty : 'a heap -> bool

(** [heap_size h] returns the size of [h] **)
val heap_size : 'a heap -> int

(** [heap_tas h] returns the array of [h] **)
val heap_tas : 'a heap -> 'a array
