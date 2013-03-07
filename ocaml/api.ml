(* pacemkr © 2013 Victor Nicollet *)

open Ohm

module Post = struct
  module T = struct
    type json t = {
      nature  : string ;
     ?id      : string option ; 
     ?alert   : int option ;    
     ?minimum : int option ;
    }
  end
  include T
  include Fmt.Extend(T)
end
