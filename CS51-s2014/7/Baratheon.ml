open Core.Std
open WorldObject
open WorldObjectI
open Human

(* Baratheons should travel in a random direction. *)
class baratheon p city : Human.human_t =
object
  inherit human p city

  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO: Part 5 Smart Humans *)

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO: Part 5 Smart Humans *)
  method! get_name = "Baratheon"

  (***********************)
  (***** Human Methods *****)
  (***********************)

  (* ### TODO: Part 5 Smart Humans *)
  method! private next_direction_default =  Some (Direction.random World.rand)

end


