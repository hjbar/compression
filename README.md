<h1> Compression </h1>

<h2> Année : L2 </h2>
<h2> Langage : OCaml </h2>

<p>
Le but de ce projet est d’écrire un programme capable de compresser puis décompresser des fichiers en utilisant l'algorithme d’Huffman.

Les commandes de compilation sont :
   - Dune clean
   - Dune build @all
   - Dune exec src/huff.exe

L'exécutable huff.exe se trouve dans _build/default/src

On peut ajouter --stats lors de l'exécution pour afficher les statistiques de la compression.
On peut également ajouter --help pour afficher un message l’utilisation de l'exécutable.
Ce dernier attend toujours soit une option, soit un fichier en argument d'exécution.
</p>
