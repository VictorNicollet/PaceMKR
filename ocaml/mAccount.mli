(* pacemkr © 2013 Victor Nicollet *)

type t = {
  secret  : string ;
  plan    : [ `Trial | `Basic ] ;
  created : float ;
  paid    : float ; 
}

val create : unit -> (#O.ctx, t * IAccount.t) Ohm.Run.t

val get : IAccount.t -> (#O.ctx, t option) Ohm.Run.t

val expired : t -> float -> bool
val expires : t -> float
