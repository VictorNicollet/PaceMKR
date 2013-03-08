(* pacemkr © 2013 Victor Nicollet *)

include Ohm.Id.PHANTOM

val make : nature:string -> ?id:string -> IAccount.t -> t
