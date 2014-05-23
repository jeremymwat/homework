(* TODO THIS *)

open Core.Std
open Helpers
open WorldObject
open WorldObjectI
open Movable
open KingsLanding

(* ### Part 3 Actions ### *)
let gold_theft_amount = 1000

(* ### Part 4 Aging ### *)
let dragon_starting_life = 20

(* ### Part 2 Movement ### *)
let dragon_inverse_speed = Some 10

class dragon p king home : movable_t =
object (self)
  inherit movable p dragon_inverse_speed as super

  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO: Part 3 Actions ### *)
  val mutable stolen_gold = 0
  (* ### TODO: Part 6 Events ### *)
  val mutable life = dragon_starting_life

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
  method private do_action () = 
if self#get_pos = king#get_pos then stolen_gold <- stolen_gold +
	        (king#forfeit_treasury gold_theft_amount (self:>world_object_i));
 if self#get_pos = home#get_pos then (ignore(stolen_gold <- 0);
 if king#get_gold < (gold_theft_amount / 2) then self#die) 




  (* ### TODO: Part 6 Custom Events ### *)

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO: Part 1 Basic ### *)

  method! get_name = "dragon"

  method! draw = super#draw_circle Graphics.red Graphics.black (string_of_int stolen_gold)

  method! draw_z_axis = 3


  (* ### TODO: Part 3 Actions ### *)

  (* ### TODO: Part 6 Custom Events ### *)

  (***************************)
  (***** Movable Methods *****)
  (***************************)

  (* ### TODO: Part 2 Movement ### *)

  method! next_direction = if stolen_gold = 0 
			   then World.direction_from_to self#get_pos king#get_pos 
			   else World.direction_from_to self#get_pos home#get_pos


  (* ### TODO: Part 6 Custom Events ### *)

  method! receive_damage = life <- life - 1; ignore(if life <= 0 then self#die)

end
