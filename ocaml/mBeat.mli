(* pacemkr © 2013 Victor Nicollet *)

(* This module is a "heartbeat queue". Heartbeats are added to this
   queue by the web server, and then polled and processed by the
   asynchronous bot servers. *)

type t = {
  id       : IBeat.t ;
  account  : IAccount.t ;
  received : float ;
  payload  : Api.Post.t list ;
}

val push : account:IAccount.t -> Api.Post.t list -> (#O.ctx,unit) Ohm.Run.t

val pop : unit -> (#O.ctx, t option) Ohm.Run.t

