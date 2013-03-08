(* pacemkr © 2013 Victor Nicollet *)

type t = {
  alive  : bool ;
  aid    : IAccount.t ;
  nature : string ;
  id     : string option ; 
  last   : float ; 
  alert  : float option ; 
  min    : int option ; 
  expect : float ;
}

val all : IAccount.t -> (#O.ctx, t list) Ohm.Run.t 

