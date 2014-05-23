open Core.Std
open Helpers
open WorldObject
open WorldObjectI

(* ### Part 6 Custom Events ### *)
let town_limit = 200

(** The Wall will spawn a white walker when there are enough towns
    in the world. *)
class wall p kingl : world_object_i =
object (self)
  inherit world_object p as wo

  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO Part 6 Custom Events ### *)

  (***********************)
  (***** Initializer *****)
  (***********************)

  (* ### TODO Part 6 Custom Events ### *)
 initializer
    self#register_handler World.action_event self#do_action


  (**************************)
  (***** Event Handlers *****)
  (**************************)

  (* ### TODO Part 6 Custom Events ### *)
 method private do_action _ = 
   if (World.fold (fun obj b -> if obj#smells_like_gold = None then b else b + 1) 0) 
      >  town_limit  && 
       (World.fold (fun obj b ->not ( obj#get_name = "white_walker") && b) true)

    then (ignore(new WhiteWalker.white_walker self#get_pos kingl (self :> world_object_i));
	  Printf.printf "White Walkers! "); flush_all ()

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO Part 1 Basic ### *)

  method! get_name = "wall"

  method! draw = wo#draw_circle Graphics.white 
				(Graphics.rgb 70 100 130) "W"

  method! draw_z_axis = 1


end

