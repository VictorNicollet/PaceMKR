(* pacemkr © 2013 Victor Nicollet *)

open Ohm

module A = Action.Args

let home,    def_home    = O.declare "" A.none
let start,   def_start   = O.declare "get-started" A.none
let account, def_account = O.declare "a" (A.r IAccount.arg) 

let beat,    def_beat    = O.declare "beat" (A.rr IAccount.arg A.string) 

