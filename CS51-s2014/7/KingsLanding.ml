open Core.Std
open Event51
open Helpers
open WorldObject
open WorldObjectI

(* ### Part 3 Actions ### *)
let starting_gold = 500
let cost_of_human = 10
let spawn_probability = 20
let gold_probability = 50
let max_gold_deposit = 20 (* 3 *)

(** King's Landing will spawn humans and serve as a deposit point for the gold
    that humans gather. It is possible to steal gold from King's Landing;
    however the city will signal that it is in danger and its loyal humans
    will become angry. *)
class kings_landing p : 
object 
  inherit world_object_i
  method forfeit_treasury : int -> world_object_i -> int
  method get_gold_event : int Event51.event
  method get_gold : int

 end =
object (self)
  inherit world_object p as super




  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO: Part 3 Actions ### *)
val mutable king_purse = starting_gold


  (* ### TODO: Part 6 Custom Events ### *)
val gold_event = Event51.new_event ()

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
    Helpers.with_inv_probability World.rand gold_probability
				 (fun () -> king_purse <- king_purse + 1);
   Helpers.with_inv_probability World.rand spawn_probability 
   (fun () -> if king_purse > cost_of_human
	      then(self#generate_human;
		   king_purse <- (king_purse - cost_of_human)))

  (* ### TODO: Part 4 Aging ### *)

  (**************************)
  (***** Helper Methods *****)
  (**************************)

  (* ### TODO: Part 4 Aging ### *)
  method private generate_human = 
Helpers.with_equal_probability World.rand  
[(fun () -> ignore(new Lannister.lannister self#get_pos (self:>world_object_i)));
(fun () -> ignore(new Baratheon.baratheon self#get_pos (self:>world_object_i)))]

				      
  (****************************)
  (*** WorldObjectI Methods ***)
  (****************************)

  (* ### TODO: Part 1 Basic ### *)

  method! get_name = "kings_landing"

  method! draw = super#draw_circle (Graphics.rgb 0xFF 0xD7 0x00) 
				(Graphics.black) (string_of_int king_purse)

  method! draw_z_axis = 1

  method! receive_gold ps = Event51.fire_event gold_event king_purse;
    king_purse <- king_purse + 
 (let g = List.length ps in if g > max_gold_deposit then max_gold_deposit else g); []

  (* ### TODO: Part 3 Actions ### *)

  (* ### TODO: Part 6 Custom Events ### *)

  (**********************************)
  (***** King's Landing Methods *****)
  (**********************************)

  (* ### TODO: Part 3 Actions ### *)
  method private forfeit_treasury n obj = self#danger obj; 
   let kp = king_purse in if n > king_purse then (king_purse <- 0; kp)
			  else (king_purse <- king_purse - n; n)								  

  (* ### TODO: Part 6 Custom Events ### *)
  method get_gold_event : int Event51.event = gold_event 

  method get_gold = king_purse

end
