(* pacemkr © 2013 Victor Nicollet *)

open Ohm

module Post = struct
  module T = struct
    type json t = {
      nature  : INature.t ;
     ?id      : string option ; 
     ?alert   : int option ;    
     ?minimum : int option ;
     ?detail  : string option ; 
    }
  end
  include T
  include Fmt.Extend(T)
end
