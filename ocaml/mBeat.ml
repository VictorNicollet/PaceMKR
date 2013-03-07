(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {
      aid         : IAccount.t ;
      t           : float ;
      payload "p" : Api.Post.t list ;
    }
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "beat" end)(IBeat)(Data)

type t = {
  id       : IBeat.t ;
  account  : IAccount.t ;
  received : float ;
  payload  : Api.Post.t list ;
}

let make bid data = {
  id       = bid ;
  account  = data.Data.aid ;
  received = data.Data.t ;
  payload  = data.Data.payload
}

let push ~account payload = 
  let! t    = ohmctx (#time) in
  let  data = Data.({ aid = account ; t ; payload }) in
  let! id   = ohm $ Tbl.create data in
  return () 

let pop () = 
  let! _, first = ohm $ Tbl.all_ids ~count:0 None in
  let! bid  = req_or (return None) first in
  let! data = ohm_req_or (return None) (Tbl.get bid) in
  let! ()   = ohm (Tbl.delete bid) in 
  return (Some (make bid data))
