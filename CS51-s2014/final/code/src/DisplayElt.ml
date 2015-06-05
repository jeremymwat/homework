open Core.Std;;
open Graphics;;

(* 2-D cartesian points *)
(*type point = int * int*)

(* Vectorized points (after shapes have been reduced/smoothed *)
type f_point = { x : float; y: float }

  (* Class type for display elements. This is the interface that display
   * elements present not only to clients, but to subclasses (in particular,
   * the inheritance interface includes the mutable variable point *)

(* returns square distance between two points *)
let get_sq_distance ( p1 : f_point) (p2 : f_point) : float =
  let dx = p1.x -. p2.x in
  let dy = p1.y -. p2.y in
  (dx *. dx) +. (dy *. dy)

(* returns square distance of a point p from a segment p1,p2 *)
let get_sq_seg_distance (p : f_point) (p1 : f_point) (p2: f_point) : float =
  let x = p1.x in
  let y = p1.y in
  let dx = p2.x -. x in
  let dy = p2.y -. y in
  (*check if p1 and p2 are no same *)
  if not (dx = 0.) || not (dy = 0.) then
    let t = ((p.x -. x) *. dx +. (p.y -. y) *. dy) /. (dx *. dx +. dy *. dy) in
    if (t > 1.) then
      let p' = { x = p2.x; y = p2.y } in
      get_sq_distance p p'
    else if t > 0. then
      let p' = {x = x +. (dx *. t); y = y +. (dy *. t)} in
      get_sq_distance p p'
    else
      get_sq_distance p p1
  else
    get_sq_distance p p1

let get_nth_point (points : f_point list) (n : int) : f_point =
  match List.nth points n with
    | None -> {x=0.; y=0.}
    | Some p -> p

let deoption (ov: 'a option) (init: 'a) : 'a =
  match ov with
  | None -> init
  | Some v -> v

module DisplayElt =
struct
  class type display_elt =
  object
    method get_color : color
    method set_color : color -> unit
    method draw      : unit
    method erase     : unit
    method convertToSVG    : string
    method convertToString : string
    method simplify  : float -> unit

  end

  class virtual  shape ?color:(col = black) =
  object (self : #display_elt)
    val mutable color = col

    method virtual draw : unit
    method virtual convertToString : string
    method virtual convertToSVG : string
    method virtual simplify  : float -> unit

    method get_color   = color
    method set_color c = color <- c

    method erase =
      let old_color = self#get_color in
      self#set_color white;
      self#draw;
      self#set_color old_color
  end
end
