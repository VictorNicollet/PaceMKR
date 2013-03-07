(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = Url.def_start begin fun req res ->
  let! _, aid = ohm (MAccount.create ()) in
  let url = Action.url Url.account () aid in
  return (Action.redirect url res) 
end 
