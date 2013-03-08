(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal
open BatPervasives

include Ohm.Id.Phantom

let make ~nature ?(id="") aid = 
  Printf.sprintf "%S%S" nature id
  |> Digest.string
  |> Digest.to_hex
  |> (fun s -> String.sub s 0 13) 
  |> ((^) (IAccount.to_string aid)) 
  |> of_string
