(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal

let () = Url.def_home begin fun req res ->

  let! body = ohm $ Asset_Home_Page.render (object
    method getStarted = Action.url Url.start () () 
  end) in

  let! title = ohm $ AdLib.get `Common_Title in

  return (Action.page (O.page ~title body) res)

end
