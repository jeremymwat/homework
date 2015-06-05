open Core.Std;;
open Array;;
open Printf;;
open List;;

(* This file contains all functionality around contour extraction. *
 * Its primary function is gen_contour_list, which is called from *
 * outside of this file.  gen_contour_list will take in a matrix of *
 * 1s and 0s and move through the image, collecting all contours that *
 * it finds. New contours are added to a mutable contour_list.  *
 * Finally, the location of the contour_list is returned *)

(* Contour point type *)
type point = (int * int)

(* This list will eventually hold all the contours *)
let contour_list : ((point list) ref) list ref = ref []

type coord = {mutable x : int; mutable y : int}

(* Keeps track of traversal through the matrix *)
let cur : coord = {x = 1; y = 1}
(* Holds the pixel from which another pixel is extered *)
let prev : coord = {x = 0; y = 1}
(* Holds the location of the central pixel during neighborhood checking *)
let c : coord = {x = 1; y = 1}
(* Holds the location of the neighbor that is being checked *)
let n : coord = {x = 0; y = 0}
(* Holds the location of the first neighbor that is checked *)
let n_start : coord = {x = 1; y = 1}
(* Holds the location of the second point that is found in a contour *)
let c_2nd : coord = {x = 0; y = 0}

(* Copies data from orig_matrix to matrix *)
let populate_matrix orig_matrix matrix w h : unit =
  for x = 0 to h - 1 do
    (for x = 0 to h - 1 do
       (for y = 0 to w - 1 do
	  matrix.(x+1).(y+1) <- orig_matrix.(x).(y)
	done)
     done)
  done

(* Returns a copy of orig_matrix with an additional border of 0s *)
let add_border orig_matrix w h : int array array =
  let matrix = Array.make_matrix (h+2) (w+2) 0 in
  let _ = populate_matrix orig_matrix matrix w h in
  matrix

(* Moves n to the next clockwise position in the neighborhood *)
let next_neighbor () : unit=
  if (c.x - n.x = 1) then
    if (c.y - n.y = 1) then (n.x <- n.x + 1)
    else if (c.y - n.y = 0) then (n.y <- n.y - 1)
    else if (c.y - n.y = (-1)) then (n.y <- n.y - 1)
    else failwith "Next Neighbor Error"
  else if (c.x - n.x = 0) then
    if (c.y - n.y = 1) then (n.x <- n.x + 1)
    else if (c.y - n.y = 0) then failwith "Next Neighbor Error"
    else if (c.y - n.y = (-1)) then (n.x <- n.x - 1)
    else failwith "Next Neighbor Error"
  else if (c.x - n.x = (-1)) then
    if (c.y - n.y = 1) then (n.y <- n.y + 1)
    else if (c.y - n.y = 0) then (n.y <- n.y + 1)
    else if (c.y - n.y = (-1)) then (n.x <- n.x - 1)
    else failwith "Next Neighbor Error"
  else failwith "Next Neighbor Error"

(* Helps move through the neighborhood *)
let rec borders_0s_helper matrix w h : bool =
  match matrix.(n.x).(n.y) with
  | 0 -> (prev.x <- n.x; prev.y <- n.y; true)
  | _ -> let _ = next_neighbor () in
	 if ((n.x, n.y) = (n_start.x, n_start.y)) then false
	 else borders_0s_helper matrix w h

(* Checks whether a 1 is surrounded by any 0s *)
let borders_0s matrix w h : bool =
  n_start.x <- prev.x; n_start.y <- prev.y;
  n.x <- n_start.x; n.y <- n_start.y;
  c.x <- cur.x; c.y <- cur.y;
  borders_0s_helper matrix w h

(* Grabs the second point in a contour *)
let rec get_c_2nd matrix new_contour : unit =
  matrix.(c.x).(c.y) <- 4;
  match matrix.(n.x).(n.y) with
  | 0 |2 -> (prev.x <- n.x; prev.y <- n.y;
	     matrix.(n.x).(n.y) <- 2;
	     let _ = next_neighbor () in
	     if (n.x <> n_start.x || n.y <> n_start.y)
	     then (get_c_2nd matrix new_contour)
	     else (c_2nd.x <- (-1); c_2nd.y <- (-1);
		   new_contour := (c.x, c.y) :: !new_contour))
  | 1 | 4 ->
	 (let temp_x = c.x in
	  let temp_y = c.y in
	  c_2nd.x <- n.x; c_2nd.y <- n.y;
	  c.x <- n.x; c.y <- n.y;
	  n.x <- prev.x; n.y <- prev.y;
	  n_start.x <- prev.x; n_start.y <- prev.y;
	  new_contour := (temp_x, temp_y) :: !new_contour)
  | _ -> failwith "Error: a contour mapping hit a 3"

(* Traces the entire contour and does not stop until it reaches the *
 * second point in the contour.  It looks for the second point to avoid *
 * infinate loops, as the first point is not always reachable *)
let rec trace_contour matrix new_contour : unit =
  matrix.(c.x).(c.y) <- 4;
  match matrix.(n.x).(n.y) with
  | 0 |2 -> (prev.x <- n.x; prev.y <- n.y;
	     matrix.(n.x).(n.y) <- 2;
	     let _ = next_neighbor () in
	     if (n.x <> n_start.x || n.y <> n_start.y)
	     then (trace_contour matrix new_contour)
	     else (new_contour := (c.x, c.y) :: !new_contour))
  | 1 | 4 ->
	 (let temp_x = c.x in
	  let temp_y = c.y in
	  c.x <- n.x; c.y <- n.y;
	  n.x <- prev.x; n.y <- prev.y;
	  n_start.x <- prev.x; n_start.y <- prev.y;
	  if (c.x <> c_2nd.x || c.y <> c_2nd.y)
	  then (new_contour := (temp_x, temp_y) :: !new_contour;
		trace_contour matrix new_contour)
	  else new_contour := (cur.x, cur.y) ::
				(temp_x, temp_y) :: !new_contour)
  | _ -> failwith "Error: a pixel value was invalid"

(* Launches a collection of contour points starting from the location of cur *)
let gen_contour matrix w h : point list ref =
  let new_contour : point list ref = ref [] in
  let _ = get_c_2nd matrix new_contour in
  let _ = if c_2nd.x = (-1) then () else (trace_contour matrix new_contour) in
  new_contour

(* Moves through the image searching for contours *)
let rec traverse matrix w h : unit =
  (match matrix.(cur.x).(cur.y) with
   | 0 -> continue matrix w h
   | 1 -> handle_1s matrix w h
   | 2 | 4 ->  continue matrix w h
   | _ -> failwith "Invalid matrix value. Range is from 0 to 4.")

(* Continues the traversal through the image, restarting at cur *)
and continue matrix w h : unit =
  prev.x <- cur.x; prev.y <- cur.y;
  if cur.y < w
  then (cur.y <- cur.y + 1; traverse matrix w h)
  else if cur.x < h
  then (cur.x <- cur.x + 1; cur.y <- 1; prev.x <- cur.x; prev.y <- 0;
	traverse matrix w h)
  else ()

(* Checks if a 1 is on a new contour. If so, launches gen_contour *)
and handle_1s matrix w h :unit =
  if (borders_0s matrix w h)
  then (n_start.x <- n.x; n_start.y <- n.y;
	contour_list := ((gen_contour matrix w h) :: !contour_list);
	continue matrix w h)
  else continue matrix w h

(* Takes in a matrix of 1s and 0s and populates the contour_list *)
let gen_contour_list orig_matrix : ((point list) ref) list ref =
  let w = Array.length orig_matrix.(0) in
  let h = Array.length orig_matrix in
  let matrix = add_border orig_matrix w h in
  let _ = traverse matrix w h in
  contour_list
