open Core.Std
open Event51
open Helpers
open WorldObject
open WorldObjectI
open Movable
open Ageable
open CarbonBased
open Direction

(* ### Part 2 Movement ### *)
let human_inverse_speed = Some 1

(* ### Part 3 Actions ### *)
let max_gold_types = 5

(* ### Part 4 Aging ### *)
let human_lifetime = 1000

(* ### Part 5 Smart Humans ### *)
let max_sensing_range = 5

(** Humans travel the world searching for towns to trade for gold.
    They are able to sense towns within close range, and they will return
    to King's Landing once they have traded with enough towns. *)
class type human_t = 
	  object 
	    inherit Ageable.ageable_t
	    method private gold_in_purse : int
	    method private next_direction_default : Direction.direction option
	  end

class human p (home:world_object_i) : human_t =
object(self)(*
  inherit world_object p as wo *)
  inherit carbon_based p human_inverse_speed (World.rand human_lifetime) human_lifetime

  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO: Part 3 Actions ### *)
  val mutable purse : int list = []

  (* ### TODO: Part 5 Smart Humans ### *)
  val sensing_range = World.rand max_sensing_range

  val gold_types = World.rand max_gold_types + 1

  (* ### TODO: Part 6 Custom Events ### *)

  val mutable dragon_danger = None

  (***********************)
  (***** Initializer *****)
  (***********************)

  (* ### TODO: Part 3 Actions ### *)
  initializer 
    self#register_handler World.action_event self#do_action;
    self#register_handler home#get_danger_event self#do_danger


  (* ### TODO: Part 6 Custom Events ### *)

  (**************************)
  (***** Event Handlers *****)
  (**************************)

  (* ### TODO: Part 6 Custom Events ### *)
  method private do_danger d = dragon_danger <- Some d;

  (**************************)
  (***** Helper Methods *****)
  (**************************)

  (* ### TODO: Part 3 Actions ### *) 
  method private deposit_gold (obj : world_object_i) : unit = purse <- obj#receive_gold purse

  method private extract_gold (obj : world_object_i) : unit = 
    match obj#forfeit_gold with
    | Some p -> purse <- p::purse
    | None -> () 

 method private do_action () = 
 if (World.fold (fun obj b -> not(obj#get_name = "dragon") && b) true)
 then dragon_danger <- None; 
 let n_list = World.get self#get_pos in List.iter n_list 
       ~f:(fun obj -> self#deposit_gold obj; self#extract_gold obj;
		      if obj#get_name = "dragon" && dragon_danger <> None
		      then (obj#receive_damage; self#die))




  (* ### TODO: Part 5 Smart Humans ### *)

 method private gold_in_purse = List.length purse

 method private magnet_gold : world_object_i option = 
(* get nearby objects *)
   let ls = World.objects_within_range self#get_pos max_sensing_range in
(* Filter out non-smelly or same-smelly objects   *)
   let fls = List.filter ls ~f:(fun x -> match x#smells_like_gold with
					 | Some v -> not(List.mem purse v)
					 | None -> false
			       )
(* get closest object *)
   in match fls with
      | [] -> None
      | hd::_ -> Some (List.fold_left fls ~init:hd ~f:(fun y a -> 
			         if distance self#get_pos y#get_pos < 
				 distance self#get_pos a#get_pos then y else a))
   

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO: Part 1 Basic ### *)

  method! get_name = "human"  

  method! draw_z_axis = 2


  (* ### TODO: Part 3 Actions ### *) 

  method! draw_picture = self#draw_circle (Graphics.rgb 0xC9 0xC0 0xBB)
				Graphics.black (string_of_int (List.length purse)) 
  (***************************)
  (***** Ageable Methods *****)
  (***************************)

  (* ### TODO: Part 4 Aging ### *)

  (***************************)
  (***** Movable Methods *****)
  (***************************)

  (* ### TODO: Part 2 Movement ### *)


 



  (* ### TODO: Part 5 Smart Humans ### *)

  (* ### TODO: Part 6 Custom Events ### *)
 method! next_direction = 
match dragon_danger with
| Some d -> World.direction_from_to self#get_pos d#get_pos
| None ->
    if List.length (Helpers.unique purse) >= max_gold_types
    then World.direction_from_to self#get_pos home#get_pos 
    else match  self#magnet_gold with
	 | Some obj -> World.direction_from_to self#get_pos obj#get_pos
	 | None -> self#next_direction_default

  (***********************)
  (**** Human Methods ****)
  (***********************)

  (* ### TODO: Part 5 Smart Humans ### *)
  method private next_direction_default = None

end
