(* pacemkr © 2013 Victor Nicollet *)

open Ohm
open Ohm.Universal
open BatPervasives

let missing res = 
  let! title = ohm $ AdLib.get `ErrorPage_Error404_Title in 
  let! html  = ohm $ Asset_ErrorPage_Error404.render () in
  let  page  = Html.print_page ~css:[Asset.css] ~body_classes:["error-page"] ~title html in
  return $ Action.page page res

let render_item now item = (object
  method name   = item.MItem.id
  method last   = (item.MItem.last, now)
  method alive  = item.MItem.alive 
  method longer = item.MItem.last +. MItem.expect item < now 
  method detail = item.MItem.detail
end)

let render_nature aid now items nature = 
  let list = 
    List.map (render_item now) 
      (List.sort (fun a b -> compare b.MItem.last a.MItem.last)
	 (List.filter (fun i -> i.MItem.nature = nature) items))
  in
  (object 
    method name  = INature.to_string nature
    method items = list
    method clean = Action.url Url.clean () (aid, nature) 
   end)

let render aid now items = 
  let natures = BatList.sort_unique compare (List.map (fun i -> i.MItem.nature) items) in
  List.map (render_nature aid now items) natures

let () = Url.def_account begin fun req res -> 

  let  aid = req # args in
  let! account = ohm_req_or (missing res) (MAccount.get aid) in

  let! now = ohmctx (#time) in
  let  expire = now, MAccount.expires account in

  let! items = ohm $ MItem.all aid in 
  let  dashboard = if items = [] then None else Some (render aid now items) in

  let! title = ohm $ AdLib.get `Common_Title in 
  let! body  = ohm $ Asset_Account_Page.render (object
    method apiUrl = Action.url Url.beat () (aid, account.MAccount.secret)
    method expire = expire
    method dashboard = dashboard
  end) in  

  return $ Action.page (O.page ~title body) res 

end 
