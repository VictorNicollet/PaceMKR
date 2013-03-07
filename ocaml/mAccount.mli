(* pacemkr © 2013 Victor Nicollet *)

type t = {
  secret  : string ;
  plan    : [ `Trial | `Basic ] ;
  created : float ;
}

val create : unit -> (#O.ctx, t * IAccount.t) Ohm.Run.t

val get : IAccount.t -> (#O.ctx, t option) Ohm.Run.t

