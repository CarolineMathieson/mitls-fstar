module Test.Main

open FStar.HyperStack.ST
open FStar.HyperStack.IO

inline_for_extraction
let check s (f: unit -> St C.exit_code): St unit =
  match f () with
  | C.EXIT_SUCCESS ->
      print_string "✔ ";
      print_string s;
      print_string "\n"
  | C.EXIT_FAILURE ->
      print_string "✘ ";
      print_string s;
      print_string "\n";
      C.exit 255l

let rec iter xs: St unit =
  match xs with
  | [] -> ()
  | x :: xs ->
      let s = fst x in
      let f = snd x in
      check s f; iter xs

let main (): St C.exit_code =
  ignore (FStar.Test.dummy ());
  iter [
    "TLSConstants", TLSConstants.main;
    "StAE", StAE.main;
    (* ADD NEW TESTS HERE *)
  ];
  C.EXIT_SUCCESS