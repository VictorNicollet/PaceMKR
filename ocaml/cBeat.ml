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

  let! account = ohm_req_or (fail "Unknown account") (MAccount.get aid) in
  let! () = true_or (fail "Invalid secret key") (secret = account.MAccount.secret) in
  
  let! time = ohmctx (#time) in
  let! () = true_or (fail "Account expired") (MAccount.expired account time) in

  let! () = ohm (MBeat.push ~account:aid beat) in
  
  return (Action.json [ "status", Json.String "ok" ] res)

end 
