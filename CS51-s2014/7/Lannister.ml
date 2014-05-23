open Core.Std
open WorldObject
open WorldObjectI
open Human


class lannister p city : Human.human_t =
object (self)
  inherit human p city as super

  (******************************)
  (***** Instance Variables *****)
  (******************************)

  (* ### TODO: Part 5 Smart Humans *)
  val mutable cur_dir = Some (Direction.random World.rand)

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO: Part 5 Smart Humans *)
  method! get_name = "Lannister"

  method! draw_picture = self#draw_circle (Graphics.yellow)
			Graphics.black (string_of_int super#gold_in_purse)
  (***********************)
  (***** Human Methods *****)
  (***********************)

  (* ### TODO: Part 5 Smart Humans *)
  method! private next_direction_default = 
    if (World.can_move (Direction.move_point self#get_pos cur_dir)) 
       then cur_dir else (cur_dir <- Some (Direction.random World.rand);
	self#next_direction_default)

end


