(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {
      secret  "s" : string ;
      plan    "p" : [ `Trial "t" | `Basic "b" ] ;
      created "c" : float ;
    }
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "account" end)(IAccount)(Data)

type t = Data.t = {
  secret  : string ;
  plan    : [ `Trial | `Basic ] ;
  created : float ;
}

let get aid = 
  Tbl.get aid 

let create () = 
  let! created = ohmctx (#time) in
  let  secret = 
    Printf.sprintf "%d%f%d" (Random.bits ()) created (Random.bits ()) 
    |> Digest.string 
    |> Digest.to_hex 
  in
  let  account = { secret ; plan = `Trial ; created } in
  let! aid = ohm (Tbl.create account) in
  return (account, aid) 
  
