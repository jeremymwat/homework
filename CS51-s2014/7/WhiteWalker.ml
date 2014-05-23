open Core.Std
open Helpers
open WorldObject
open WorldObjectI
open Movable

(* ### Part 2 Movement ### *)
let walker_inverse_speed = Some 1

(* ### Part 6 Custom Events ### *)
let max_destroyed_objects = 100

(** A White Walker will roam the world until it has destroyed a satisfactory
    number of towns *)
class white_walker p king home : movable_t =
object (self)
  inherit movable p walker_inverse_speed as super

  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO: Part 3 Actions ### *)
  val mutable destroyed = 0

  (***********************)
  (***** Initializer *****)
  (***********************)

  (* ### TODO: Part 3 Actions ### *)
  initializer 
    self#register_handler World.action_event self#do_action
  (**************************)
  (***** Event Handlers *****)
  (**************************)

  (* ### TODO: Part 3 Actions ### *)
  method private do_action () = let n_list = World.get self#get_pos in List.iter n_list 
 ~f:(fun obj -> if not (obj#smells_like_gold = None) && self#is_dangerous
		then (destroyed <- destroyed + 1; obj#die)); 
		     if not(self#is_dangerous) && self#get_pos = home#get_pos
		     then self#die
				

  (* ### TODO: Part 6 Custom Events ### *)

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO: Part 1 Basic ### *)

  method! get_name = "white_walker"




  method! draw_z_axis = 4


  (* ### TODO: Part 3 Actions ### *)
  method! draw = super#draw_circle (Graphics.rgb 0x89 0xCF 0xF0)
	        (Graphics.rgb 0x89 0xCF 0xF0) (string_of_int destroyed)

  (***************************)
  (***** Movable Methods *****)
  (***************************)

  (* ### TODO: Part 2 Movement ### *)

 method! next_direction = if self#is_dangerous then 
			    Helpers.with_inv_probability_or World.rand (World.size/2) 
			  (fun () -> World.direction_from_to self#get_pos king#get_pos)
		          (fun () -> Some (Direction.random World.rand))
			  else World.direction_from_to self#get_pos home#get_pos



  (* ### TODO: Part 6 Custom Events ### *)

 method private is_dangerous = destroyed < max_destroyed_objects

end
