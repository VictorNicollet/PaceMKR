(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal
open BatPervasives

let missing res = 
  let! title = ohm $ AdLib.get `ErrorPage_Error404_Title in 
  let! html  = ohm $ Asset_ErrorPage_Error404.render () in
  let  page  = Html.print_page ~css:[Asset.css] ~body_classes:["error-page"] ~title html in
  return $ Action.page page res

let () = Url.def_account begin fun req res -> 
  let  aid = req # args in
  missing res
end 
