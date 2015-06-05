open Core.Std;;
open DisplayElt;;
open Graphics;;

(* Interface for handling user intraction with polyline *)
class type polyline_i =
object

  inherit DisplayElt.display_elt

  (* count number of vertices in a polyline *)
  method vertexCount : int

  (* add a vertex at end *)
  method addVertex : f_point -> unit

  (* append list of vertexes *)
  method appendVertexes : f_point list -> unit
end

(* polyline class to represent polyline objects,
 * inherits class DisplayElt.shape *)
class polyline ?(color : color option) : polyline_i =
object (self)
  inherit DisplayElt.shape ?color

  val mutable vertexes : f_point list = []

  (* draw polyline to graphics window *)
  method draw = set_color color;
		let points = List.map ~f:(fun p -> Float.to_int p.x,
						   Float.to_int p.y)
				      vertexes in
		draw_poly_line (Array.of_list points)

  (* count number of vertices in a polyline *)
  method vertexCount = List.length vertexes

  (* add a vertext at end *)
  method addVertex p  = vertexes <- vertexes @ [p]

  (* appends list of vertexes to a polyline *)
  method appendVertexes pl = vertexes <- vertexes @ pl

  (* return a path element string e.g. <path d="M 150 0 L 75 200 L 225 200"/> *)
  method convertToSVG =
    (* initialize SVG path element *)
    let path = "<path d=\"M" in
    let tag_end = "\" stroke=\"black\" stroke-width=\"2\" fill=\"none\"/>\n" in

    (* parse point list into path string, leaves extra " L" at end *)
    let path =
      List.fold_left
	~f:(fun path p ->
	    path ^ " "
	    ^ (Float.to_string p.x) ^ " "
	    ^ (Float.to_string p.y) ^ " L")
	~init:path vertexes in

    (* remove extra " L" from end of path and close out tag *)
    let length = String.length path in
    let path = (String.sub path ~pos:0 ~len:(length - 2)) ^ tag_end in
    path

  (* convert a polyline to ascii string *)
  method convertToString =
    "START\n"
    ^ (List.fold_right
	 ~f:(fun p r -> (Printf.sprintf "%f %f" p.x p.y) ^ "\n" ^ r)
	 ~init:"" vertexes)
    ^ "END POLY\n"

  (* simplify polyline using radial distance and Douglous-Peucker algorithms *)
  method simplify (t : float) =
    let sqTolerance = t *. t in
    self#simplifyRadialDist sqTolerance;
    self#simplifyDouglasPeucker sqTolerance

  (* basic distance-based simplification *)
  method private simplifyRadialDist (sqTolerance : float) =
    let rec loop prev points =
      match points with
      | [] -> []
      | p :: [] -> [p]
      | p :: ps' ->
	 if get_sq_distance prev p > sqTolerance then
	   p :: loop p ps'
	 else
	   loop prev ps'
    in
    match vertexes with
    | [] -> ()
    | v :: vs -> vertexes <- v :: loop v vs

  (* Douglas-Peucker algorithm to simplify polyline *)
  method private simplifyDouglasPeucker (sqTolerance : float) =
    let len = List.length vertexes in
    let markers = Array.create len 0 in
    let first = ref 0 in
    let last = ref (len - 1) in
    let stack = Stack.create () in
    Array.set markers !first 1;
    Array.set markers !last 1;

    while not (!last = 0) do
      let maxSqDist = ref 0. in
      let index = ref 0 in
      let pfirst = get_nth_point vertexes !first in
      let plast = get_nth_point vertexes !last in
      for i = !first + 1 to !last - 1 do
	let p = get_nth_point vertexes i in
	let sqDist = get_sq_seg_distance p pfirst plast in
	(if sqDist > !maxSqDist then
	   (maxSqDist := sqDist;
	    index := i));
      done;
      (if !maxSqDist > sqTolerance then
	 (Array.set markers !index 1;
	  Stack.push stack !first;
	  Stack.push stack !index;
	  Stack.push stack !index;
	  Stack.push stack !last));
      last := deoption (Stack.pop stack) 0;
      first := deoption (Stack.pop stack) 0;
    done;

    let newpoints = ref [] in
    for i = 0 to len - 1 do
      (if (Array.get markers i) = 1 then
	 let p = get_nth_point vertexes i in
	 newpoints := p :: !newpoints);
    done;
    vertexes <- List.rev !newpoints

end
