open Core.Std;;
open DisplayElt;;
open GraphicsEvents;;
open Polyline;;
open Scene;;
open Edge;;
open Contour;;
open OImages;;

module Ras2Vec =
struct

  let sc = new scene (800, 600)

  (* called when a key is pressed and selects the appropriate
   * color and re-draws the ball, or terminates the event loop. *)
  let key_handler (c : char) : unit =
    (match c with
       | 'q' -> GraphicsEvents.terminate ()
       | _ -> ())

  let smoothPolyline () =
    let points : f_point list =[{x=224.55;y=250.15};{x=226.91;y=244.19};{x=233.31;y=241.45};{x=234.98;y=236.06};{x=244.21;y=232.76};{x=262.59;y=215.31};{x=267.76;y=213.81};{x=273.57;y=201.84};{x=273.12;y=192.16};{x=277.62;y=189.03};{x=280.36;y=181.41};{x=286.51;y=177.74};{x=292.41;y=159.37};{x=296.91;y=155.64};{x=314.95;y=151.37};{x=319.75;y=145.16};{x=330.33;y=137.57};{x=341.48;y=139.96};{x=369.98;y=137.89};{x=387.39;y=142.51};{x=391.28;y=139.39};{x=409.52;y=141.14};{x=414.82;y=139.75};{x=427.72;y=127.30};{x=439.60;y=119.74};{x=474.93;y=107.87};{x=486.51;y=106.75};{x=489.20;y=109.45};{x=493.79;y=108.63};{x=504.74;y=119.66};{x=512.96;y=122.35};{x=518.63;y=120.89};{x=524.09;y=126.88};{x=529.57;y=127.86};{x=534.21;y=140.93};{x=539.27;y=147.24};{x=567.69;y=148.91};{x=575.25;y=157.26};{x=580.62;y=158.15};{x=601.53;y=156.85};{x=617.74;y=159.86};{x=622.00;y=167.04};{x=629.55;y=194.60};{x=638.90;y=195.61};{x=641.26;y=200.81};{x=651.77;y=204.56};{x=671.55;y=222.55};{x=683.68;y=217.45};{x=695.25;y=219.15};{x=700.64;y=217.98};{x=703.12;y=214.36};{x=712.26;y=215.87};{x=721.49;y=212.81};{x=727.81;y=213.36};{x=729.98;y=208.73};{x=735.32;y=208.20};{x=739.94;y=204.77};{x=769.98;y=208.42};{x=779.60;y=216.87};{x=784.20;y=218.16};{x=800.24;y=214.62};{x=810.53;y=219.73};{x=817.19;y=226.82};{x=820.77;y=236.17};{x=827.23;y=236.16};{x=829.89;y=239.89};{x=851.00;y=248.94};{x=859.88;y=255.49};{x=865.21;y=268.53};{x=857.95;y=280.30};{x=865.48;y=291.45};{x=866.81;y=298.66};{x=864.68;y=302.71};{x=867.79;y=306.17};{x=859.87;y=311.37};{x=860.08;y=314.35};{x=858.29;y=314.94};{x=858.10;y=327.60};{x=854.54;y=335.40};{x=860.92;y=343.00};{x=856.43;y=350.15};{x=851.42;y=352.96};{x=849.84;y=359.59};{x=854.56;y=365.53};{x=849.74;y=370.38};{x=844.09;y=371.89};{x=844.75;y=380.44};{x=841.52;y=383.67};{x=839.57;y=390.40};{x=845.59;y=399.05};{x=848.40;y=407.55};{x=843.71;y=411.30};{x=844.09;y=419.88};{x=839.51;y=432.76};{x=841.33;y=441.04};{x=847.62;y=449.22};{x=847.16;y=458.44};{x=851.38;y=462.79};{x=853.97;y=471.15};{x=866.36;y=480.77}]
    in
    let polyline = new polyline ~color:Graphics.black in
    polyline#appendVertexes points;
    sc#addShape (polyline :> DisplayElt.shape);
    let polyline2 = new polyline ~color:Graphics.red in
    polyline2#appendVertexes points;
    Printf.printf "No. of nodes: %d\n" polyline2#vertexCount;
    polyline2#simplify 5.;
    Printf.printf "No. of nodes222: %d\n" polyline2#vertexCount;
    sc#addShape (polyline2 :> DisplayElt.shape)

  let createScene () =
    let polyline = new polyline ~color:Graphics.black in
    polyline#addVertex {x=0.;y=0.};
    polyline#addVertex {x=10.;y=40.};
    polyline#addVertex {x=20.;y=50.};
    polyline#addVertex {x=30.;y=60.};
    sc#addShape (polyline :> DisplayElt.shape);

    let polyline2 = new polyline ~color:Graphics.red in
    polyline2#addVertex {x=10.;y=0.};
    polyline2#addVertex {x=110.;y=140.};
    polyline2#addVertex {x=120.;y=150.};
    polyline2#addVertex {x=130.;y=160.};
    sc#addShape (polyline2 :> DisplayElt.shape)

  (* The simple application calls Event.run telling it to add
   * key_handler to the key_pressed event listeners, and then
   * draws the initial version of the (yellow) ball. *)
  let draw () =
    GraphicsEvents.clear_listeners ();
    GraphicsEvents.key_pressed#add_listener_ key_handler;
    GraphicsEvents.run (fun () -> sc#draw)

  let view_test () =
    (*createScene();*)
    smoothPolyline();
    draw ();
    sc#writePLY "test2.ply";
    sc#writeSVG "test2.svg"

  let view_image imgfile () =
    print_string "This function will draw an image to graphics window\n"

  let view_ply plyfile () =
    sc#readPLY plyfile;
    draw ()

  (* retruns edge image and matrix from imgfile with specified algorithm *)
  let get_edge_image (algo : string) (imgfile : string) : rgb24 (* * int array array*) =
    let src = OImages.rgb24 (OImages.load imgfile []) in
    match algo with
    | "canny" -> Edge.canny_img src
    | "gauss" -> Edge.gauss src
    | "none" -> src
    | "sobelgauss" -> Edge.sobel_img (Edge.gauss src)
    | _ -> Edge.canny_img src

  (* adds list of contours extracted from matrix to the scene *)
  let matrix_to_scene (matrix : int array array) (scn : scene): unit =
    let contours : ((point list) ref) list ref = Contour.gen_contour_list matrix in

    let ipoints_to_fpoints (iplist: point list) : f_point list = 
      List.fold_right iplist ~f:(fun (ix,iy) tl -> ({x=Int.to_float ix; y=Int.to_float iy} : f_point)::tl) ~init:([] : f_point list) in

    let points_to_polyline (ipoints : point list) : polyline_i =
       let pline = new polyline ~color:Graphics.black in
       pline#appendVertexes (ipoints_to_fpoints ipoints);
       pline in

    let polylines = List.fold_right !contours ~f:(fun ips tl -> (points_to_polyline !ips)::tl) ~init:[] in
    List.iter ~f:(fun poly -> scn#addShape (poly :> DisplayElt.shape)) polylines; ()

  let image_to_image algo imgfile () =
    let outputfile = (Filename.chop_extension imgfile) ^ ".img" in
    let img = get_edge_image algo imgfile in
    img#save outputfile None []; ()
    
  let image_to_ply algo imgfile () =
    let plyfile = (Filename.chop_extension imgfile) ^ ".ply" in
    Printf.printf "This will read image file '%s' and output ply file '%s'\n" imgfile plyfile;
    let matrix = Edge.canny_mat (get_edge_image "none" imgfile) in
    let _ = matrix_to_scene matrix in
    sc#writePLY plyfile
  
  let image_to_svg algo imgfile () =
    let svgfile = Filename.chop_extension imgfile ^ ".svg" in
    Printf.printf "This will read image file '%s' and output svg file '%s'\n" 
		  imgfile svgfile;
    let mat = 
      match algo with 
      | "sobel" -> Edge.sobel_mat (get_edge_image "none" imgfile)
      | "canny" -> Edge.canny_mat (get_edge_image "none" imgfile)
      | _ -> failwith "impossible"
    in
    let w = (Array.length mat.(0) + 2) in
    let h = (Array.length mat + 2) in
    let scn = new scene (h, w) in
    let _ = matrix_to_scene mat scn in
    scn#simplifyPolylines 1.0;
    scn#writeSVG svgfile
	
  let usage () =
    Printf.printf "usage: %s [canny|sobel] <input file>\n" Sys.argv.(0);
    Printf.printf "supported image formats: jpg, png\n";
    exit 1

  (* Parse command-line arguments. Returns the appropriate initialization
   * function to run and the current part. *)
  let parse_args () : (unit -> unit) =
    if Array.length Sys.argv < 2 then usage ()
    else if Array.length Sys.argv = 2 then image_to_svg "canny" Sys.argv.(1)
    else if Array.length Sys.argv = 3 then
      (match Sys.argv.(1) with
       | "canny" | "sobel" ->
		    image_to_svg Sys.argv.(1) Sys.argv.(2)
       | _ -> usage() )
    else (* for debugging purposes *)
      match Sys.argv.(2) with
      | "test" -> view_test
      | "ply" ->  view_ply Sys.argv.(3)
      | "i2i" ->  image_to_image Sys.argv.(1) Sys.argv.(3)
      | "i2p" ->  image_to_ply Sys.argv.(1) Sys.argv.(3)
      | _ -> usage ()

  let run () : unit =
    let initialize = parse_args () in
    initialize ()

end

let _ = Ras2Vec.run ();;
