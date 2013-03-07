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
      paid    "m" : float ; 
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
  paid    : float ; 
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
  let  account = { secret ; plan = `Trial ; created ; paid = 0.0 } in
  let! aid = ohm (Tbl.create account) in
  return (account, aid) 
  
let one_month_later time = 
  let t = Unix.localtime time in
  let t' = Unix.({ t with tm_mon = t.tm_mon + 1 }) in
  fst (Unix.mktime t')

let expires account = 
  match account.Data.plan with 
    | `Trial -> one_month_later account.Data.created
    | `Basic -> one_month_later account.Data.paid

let shortest_month = 28. *. 24. *. 3600.
let longest_month = 31. *. 24. *. 3600.

let expired account now = 
  (* Avoid complex calls to unix localtime functions by 
     using a heuristic that only causes localtime to be
     computed when an account has expired between 28 and 
     31 days ago. 
  *)
  let last = match account.Data.plan with 
    | `Trial -> account.Data.created
    | `Basic -> account.Data.paid
  in
  (last +. longest_month <= now) 
  && ((last +. shortest_month > now) || (expires account > now))
