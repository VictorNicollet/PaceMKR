(* pacemkr © 2013 Victor Nicollet *)

type t = {
  alive  : bool ;
  aid    : IAccount.t ;
  nature : string ;
  detail : string option ; 
  id     : string option ; 
  first  : float ; 
  last   : float ; 
  alert  : float option ; 
  min    : int option ; 
  expect : float ;
}

val all : IAccount.t -> (#O.ctx, t list) Ohm.Run.t 

val uptime : t -> float 

(** When is a given item expected to ping again ? 
    After this duration has elapsed, the item will turn grey. 
*)
val expect : t -> float
