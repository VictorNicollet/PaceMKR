(* © 2012 RunOrg *) 

open Ohm
open BatPervasives

module Controllers = struct
  open CErrorPage
  open CHome
  open CBeat
end

let () = Random.self_init () 

module Main = Ohm.Main.Make(O.Reset)
let _ = Main.run ~async:O.run_async O.role


