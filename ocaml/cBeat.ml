(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal
open BatPervasives

module ArgFmt = Fmt.Make(struct 
  type json t = (Api.Post.t list) 
end)

let () = Url.def_beat begin fun req res ->  

  let fail message = return (Action.json [ 
    "status", Json.String "error" ; 
    "reason", Json.String message 
  ] res) in
  
  let! json = req_or (fail "Expected JSON POST") (Action.Convenience.get_json req) in
  let! beat = req_or (fail "Invalid JSON format") (ArgFmt.of_json_safe json) in
  let  aid, secret = req # args in
  (* TODO : check that aid + secret are valid *)
  let! () = ohm (MBeat.push ~account:aid beat) in
  
  return (Action.json [ "status", Json.String "ok" ] res)

end 
