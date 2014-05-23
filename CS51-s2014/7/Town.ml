open Core.Std
open Helpers
open WorldObject
open WorldObjectI
open Ageable
open CarbonBased

(* ### Part 3 Actions ### *)
let next_gold_id = ref 0
let get_next_gold_id () =
  let p = !next_gold_id in incr next_gold_id ; p

(* ### Part 3 Actions ### *)
let max_gold = 5
let produce_gold_probability = 50
let expand_probability = 4000
let forfeit_gold_probability = 3

(* ### Part 4 Aging ### *)
let town_lifetime = 2000

(** Towns produce gold.  They will also eventually die if they are not cross
    pollenated. *)
class town p gold_id : ageable_t =
object (self)
  inherit carbon_based p None (World.rand town_lifetime) town_lifetime as super

  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO: Part 3 Actions ### *)
  val mutable town_purse = World.rand max_gold

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
  method private do_action () = if town_purse < max_gold then
    Helpers.with_inv_probability World.rand produce_gold_probability
				 (fun () -> town_purse <- town_purse + 1);
    Helpers.with_inv_probability World.rand expand_probability
     ( fun () -> World.spawn 1 self#get_pos (fun l -> ignore (new town l gold_id )));()

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO: Part 1 Basic ### *)

  method! get_name = "town"

   method! draw_z_axis = 1

  method! smells_like_gold = if town_purse > 0 then Some gold_id else None

  method! forfeit_gold = if town_purse > 0 
			 then Helpers.with_inv_probability_or 
				World.rand forfeit_gold_probability  
   ( town_purse <- town_purse - 1; fun () -> Some gold_id ) 
   (fun () -> None) else None
 

  (* ### TODO: Part 4 Aging ### *)
 method! draw_picture = super#draw_circle (Graphics.rgb 0x96 0x4B 0x00)
				(Graphics.white) (string_of_int town_purse)

  (* ### TODO: Part 3 Actions ### *)

  (* ### TODO: Part 4 Aging ### *)

 method! receive_gold gld = if List.exists gld
	   ~f:(fun typ -> not (typ = gold_id)) then (self#reset_life; gld)
			    else gld

end
