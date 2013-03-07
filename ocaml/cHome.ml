(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal

let () = Url.def_home begin fun req res ->

  let aid = IAccount.gen () in

  let! body = ohm $ Asset_Home_Page.render (object
    method getStarted = Action.url Url.account () aid 
  end) in

  let title = "pacemkr - monitor your heartbeats" in

  return (Action.page (O.page ~title body) res)

end
