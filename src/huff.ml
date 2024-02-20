open Huffman

(* On decompresse le fichier s'il termine par .hf, on compresse sinon *)
let compress_or_decompress f =
  if Filename.extension f = ".hf" then decompress f else compress f false

(* On compresse mais en affichant les statistiques *)
let compress_with_stats f = compress f true

(* Gere les options + appel et initialise les fonctions ci-dessus *)
let () =
  let usage_msg =
    "\n\
     Help Message\n\n\
    \  compresse the given file (or decompress it if it ends with .hf)"
  in
  let speclist =
    [ ( "--stats"
      , Arg.String compress_with_stats
      , "compresse le fichier en affichant les stats" )
    ]
  in
  Arg.parse speclist compress_or_decompress usage_msg

(* Leve une erreur si il n'a pas de fichier a compresser/decompresser *)
let () =
  if Array.length Sys.argv < 2 then begin
    Format.eprintf "usage: %s <file>@\n" Sys.argv.(0);
    exit 1
  end
