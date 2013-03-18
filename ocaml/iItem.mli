(* pacemkr © 2013 Victor Nicollet *)

include Ohm.Id.PHANTOM

val make : nature:INature.t -> ?id:string -> IAccount.t -> t
