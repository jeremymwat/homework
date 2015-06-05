open Core.Std;;
open DisplayElt;;
open Polyline;;


(* Interface for handling scene objects like list of polyline *)
class type scene_i =
object

  (* count number of objects in a scene *)
  method countObjects : int

  (* add a scene object *)
  method addShape : DisplayElt.shape -> unit

  (* read a ply file and populate scene *)
  method readPLY : string -> unit

  (* write to ply file *)
  method writePLY : string -> unit

  (* write svg file *)
  method writeSVG : string -> unit

  (* simplify polyline *)
  method simplifyPolylines : float -> unit

  (* draw scene to a graphics window *)
  method draw : unit
end

class scene (canvas_size : int * int) : scene_i =
object (self)

  val mutable shapes : DisplayElt.shape list = []

  (* count number of objects in a scene *)
  method countObjects = List.length shapes

  (* add a shape object to scene *)
  method addShape s = shapes <- s :: shapes

  (* read a ply file and populate scene *)
  method readPLY plyfile =
    let _ = Printf.printf "Reading '%s'\n" plyfile in
    let _ = flush_all() in
    let ch = open_in plyfile in
    try
      let points = ref [] in
      while true; do
	let line = input_line ch in
	match line with
	| "START" -> points := []
	| "END POLY" -> let poly = new polyline ~color:Graphics.black in
		   poly#appendVertexes !points;
		   self#addShape (poly :> DisplayElt.shape)
	| s -> Scanf.sscanf s "%f %f" (fun a b -> points := {x=a;y=b} :: !points)
      done
    with End_of_file ->
      In_channel.close ch

  (* write to ply file *)
  method writePLY plyfile =
    let shapetext = List.fold_right ~f:(fun x r -> x#convertToString ^ r)
				   ~init:"" shapes in
    let oc = open_out plyfile in   (* create or truncate file, return channel *)
    fprintf oc "%s\n" shapetext;   (* write something *)
    Out_channel.close oc;          (* flush and close the channel *)

  (*** HELPERS FOR writeSVG ***)
  (* returns a string with the SVG file header *)
  method private svgHeader (canvas_size : int * int) : string =
    let (x, y) = canvas_size in
    let str_x = Int.to_string x in
    let str_y = Int.to_string y in
    let header =
      "<?xml version=\"1.0\" standalone=\"no\"?>\n"
      ^ "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n"
      ^ "\t\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n"
      ^ "<svg width=\"" ^ str_x ^ "\" height=\"" ^ str_y ^ "\" version=\"1.1\" "
      ^ "xmlns=\"http://www.w3.org/2000/svg\">\n" in
    header
  (*** END writeSVG HELPERS ***)

  (* write svg file *)
  method writeSVG (svgfile : string) : unit =
    let file_p = open_out svgfile in

    (* write SVG header *)
    output_string file_p (self#svgHeader canvas_size) ;

    (* call convertToSVG on each polyline in the list *)
    List.iter ~f:(fun s -> output_string file_p s#convertToSVG) shapes ;

    (* close the SVG tag *)
    output_string file_p "\n</svg>\n" ;
    Out_channel.close file_p

  (* smooth polyline *)
  method simplifyPolylines (tol : float) =
    List.iter ~f:(fun s -> s#simplify tol) shapes

  (* draw scene to a graphics window *)
  method draw = List.iter ~f:(fun s -> s#draw) shapes

end
