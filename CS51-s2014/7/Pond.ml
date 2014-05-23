open Core.Std
open WorldObject
open WorldObjectI

(** Ponds serve as obstruction for other world objects. *)
class pond p : world_object_i =
object (self)
  inherit world_object p

  (********************************)
  (***** WorldObjectI Methods *****)
  (********************************)

  (* ### TODO: Part 1 Basic ### *)

  method! get_name = "pond"

  method! draw = self#draw_circle Graphics.blue Graphics.blue ""

  method! draw_z_axis = 1

  method! is_obstacle = true

end
