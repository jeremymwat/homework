open Core.Std
open Event51
open WorldObject
open WorldObjectI

(* ### Part 6 Custom Events ### *)
let spawn_dragon_gold = 500

(** Dany will spawn a dragon when King's Lnading has collected a certain
    amount of gold. *)
class dany p kingl : world_object_i =
object (self)
  inherit world_object p

  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO: Part 6 Custom Events ### *)

  (***********************)
  (***** Initializer *****)
  (***********************)

  (* ### TODO: Part 6 Custom Events ### *)
  initializer
    self#register_handler kingl#get_gold_event self#do_action

  (**************************)
  (***** Event Handlers *****)
  (**************************)

  (* ### TODO: Part 6 Custom Events ### *)
  method private do_action gold =  if (gold > spawn_dragon_gold) &&
       ( World.fold (fun obj b -> not (obj#get_name = "dragon") && b) true)

  then (ignore(new Dragon.dragon self#get_pos kingl (self :> world_object_i));
Printf.printf "Dragon! ");  flush_all ()
    

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO: Part 1 Basic ### *)

  method! get_name = "Dany"

  method! draw =  self#draw_circle  (Graphics.rgb 0x80 0x00 0x80) 
				   Graphics.black "D"

  method! draw_z_axis = 1


  (* ### TODO: Part 6 Custom Events *)

end
