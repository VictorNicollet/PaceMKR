(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open BatPervasives

module Controllers = struct
  open CErrorPage
  open CHome
  open CBeat
  open CAccount
  open CStart
end

let () = Random.self_init () 

module Main = Ohm.Main.Make(O.Reset)
let _ = Main.run ~async:O.run_async O.role


