(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal

module Data = struct
  module T = struct
    type json t = {
      alive  : bool ;
      aid    : IAccount.t ;
      nature : string ;
      id     : string option ; 
      last   : float ; 
      alert  : float option ; 
      min    : int option ; 
      expect : float ;
    }
  end
  include T 
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "item" end)(IItem)(Data)

type t = Data.t = {
  alive  : bool ;
  aid    : IAccount.t ;
  nature : string ;
  id     : string option ; 
  last   : float ; 
  alert  : float option ; 
  min    : int option ; 
  expect : float ;
}

(* Grab all items for an account -------- *)

module ByAccountView = CouchDB.DocView(struct
  module Key = IAccount
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "by_account"
  let map = "emit(doc.aid)"
end)

let all aid = 
  let! list = ohm $ ByAccountView.doc aid in 
  return (List.map (#doc) list) 

(* Updating items by polling the heartbeats -------- *)

let register_heartbeat ~nature ?id ?alert ?min ~last aid = 

  let default expect = { 
    alive = true ;
    aid   ;
    nature ;
    id ; 
    alert ;
    min ; 
    last ;
    expect ; 
  } in

  let update = function 
    | None -> default (5. *. 60.)
    | Some current -> if current.last >= last then current else 
	let expect = 0.1 *. (last -. current.last) +. 0.9 *. current.expect in 
	default expect
  in

  let iid = IItem.make ~nature ?id aid in

  Tbl.replace iid update

let seconds minutes = 
  float_of_int minutes *. 60.

let () = 
  O.async # periodic 1 begin 
    let! () = ohm $ return () in
    let! next = ohm_req_or (return (Some 2.0)) (MBeat.pop ()) in
    let! () = ohm $ Run.list_iter begin fun post ->
      register_heartbeat 
	~nature:post.Api.Post.nature
	?id:post.Api.Post.id
	?alert:(BatOption.map seconds post.Api.Post.alert)
	?min:post.Api.Post.minimum
	~last:next.MBeat.received
	next.MBeat.account
    end next.MBeat.payload in 
    return None
  end 

