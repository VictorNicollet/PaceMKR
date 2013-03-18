(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal

module Data = struct
  module T = struct
    type json t = {
      alive  : bool ;
      aid    : IAccount.t ;
      nature : INature.t ;
     ?detail : string option ; 
      id     : string option ; 
     ?first  : float = 0.0 ;
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
  nature : INature.t ;
  detail : string option ;
  id     : string option ;
  first  : float ; 
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

let register_heartbeat ~nature ?detail ?id ?alert ?min ~last aid = 

  let default first expect = { 
    alive = true ;
    aid   ;
    nature ;
    detail ; 
    id ; 
    alert ;
    min ; 
    first = BatOption.default last first ; 
    last ;
    expect ; 
  } in

  let update = function 
    | None -> default None (5. *. 60.)
    | Some current -> if current.last >= last then current else 
	let expect = 0.1 *. (last -. current.last) +. 0.9 *. current.expect in 
	default (Some current.first) expect
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
	?detail:post.Api.Post.detail
	?id:post.Api.Post.id
	?alert:(BatOption.map seconds post.Api.Post.alert)
	?min:post.Api.Post.minimum
	~last:next.MBeat.received
	next.MBeat.account
    end next.MBeat.payload in 
    return None
  end 

(* Updating items by applying their "next update" time -------- *)

module ByNextTime = CouchDB.DocView(struct
  module Key = Fmt.Float
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "by_next_time"
  let map = "if (doc.alive && doc.alert) emit(doc.alert + doc.last)"
end)

let kill now id = 
  Tbl.update id begin fun item ->
    match item.alert with None -> item | Some duration -> 
      if item.last +. duration < now then { item with alive = false } else item
  end 

let () =  
  O.async # periodic 1 begin 
    let! now = ohmctx (#time) in
    let! next = ohm (ByNextTime.doc_query ~limit:1 ~endkey:now ()) in
    match next with [] -> return (Some 2.0) | kvd :: _ ->
      let id = IItem.of_id (kvd # id) in
      let! () = ohm $ kill now id in
      return None
  end 

let uptime t = 
  t.last -. t.first 

let expect t = 
  let minimum = 60.0  in (* Our lowest resolution is one minute *)
  let maximum = 600.0 in (* The maximum "bonus" is ten minutes. *)
  let bonus = min maximum t.expect in
  max minimum (bonus +. t.expect) 

let expired item now = 
  item.last +. expect item < now

(* Cleaning up items by nature -------------------------------- *)

module ByNature = CouchDB.DocView(struct
  module Key = Fmt.Make(struct type json t = (IAccount.t * INature.t) end)
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "by_nature"
  let map = "emit([doc.aid,doc.nature])"
end)

let clean aid nid = 
  let! now  = ohmctx (#time) in
  let! list = ohm $ ByNature.doc (aid,nid) in
  Run.list_iter begin fun x -> 
    let iid  = IItem.of_id (x # id) in
    let item = x # doc in
    if not item.alive || expired item now then
      Tbl.delete iid 
    else
      return () 
  end list
