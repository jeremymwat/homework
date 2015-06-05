(* edge finding algorithm *)


open Images;;
open OImages;;
open Core.Std;;

(* Constants for later use *)
let pi = 4. *. atan (1.);;
let white = {r=255;g=255;b=255}
let black = {r=0;g=0;b=0}

(* high threshold and low threshold for hysteresis *)
let ht = 100
let lt = 30

exception TODO

(* convolve a point in a grayscale image with a n by n matrix *)

let conv (img : rgb24) (xi : int) (yi : int) (f : int->int->int)
	 ?div:(div=1) (kern : int array array) : rgb * float =
  let acc = ref 0 in
  let k = (Array.length kern) / 2 in
  for x = (-k) to k do
    for y = (-k) to k do
      let xo = if (xi + x < 0) || (xi + x > xi) then xi else xi + x in
      let yo = if (yi + y < 0) || (yi + y > yi) then yi else yi + y in 
      acc := !acc + (f (img#get xo yo).r kern.(x+k).(y+k) );
    done
  done; 
  let dir = (abs !acc) (*/ div *) in acc := (abs !acc) / div;
  let color = (if !acc < 0 then 0 else if !acc > 255 then 255 else !acc) in
  {r = color; g = color; b = color}, Int.to_float dir
;;
      
(* helper function to put two convolutions together *)

let mash (col1 : rgb) (col2 : rgb) : rgb = 
  let x = sqrt(float(col1.r * col1.r + col2.r * col2.r)) in
  let c = let f = Float.to_int x in 
	  if f < 0 then 0 else if f > 255 then 255 else f
  in { r = c; g = c; b = c}

(* runs image through Sobel algorithm, returns image as well
 * as a matrix representing the direction of the gradient at
 * each point.
 *)

let sobel (src:rgb24) : rgb24 * float array array * int array array=
  let w = src#width in
  let h = src#height in
  let out = new rgb24 w h in
  let dirq = Array.make_matrix w h 0.0 in
  let sobmat = Array.make_matrix w h 0 in
  let sobelx = let lsmat = [[(-1);(-2);(-1)];[0;0;0];[1;2;1]] in
	       Array.of_list (List.map lsmat ~f:(Array.of_list)) in
  let sobely = let lsmat = [[1;0;(-1)];[2;0;(-2)];[1;0;(-1)]] in
	     Array.of_list (List.map lsmat ~f:(Array.of_list)) in
  for x = 0 to w - 1 do
    for y = 0 to h - 1 do
      let cx,dx = (conv src x y ( * ) sobelx) in
      let cy,dy =  (conv src x y ( * ) sobely) in
      out#set x y (mash cx cy );
      if (out#get x y).r > 0 then sobmat.(x).(y) <- 1; 
      dirq.(x).(y) <- ((atan2 dy dx) +. (pi /. 8.)) /. (pi /. 4.);
    done
  done;
 (out,dirq,sobmat)      
;;      
  
(* applies a gaussian filter to an image *)

let gauss (src:rgb24) : rgb24 = 
  let w = src#width in
  let h = src#height in
  let out = new rgb24 w h in
  let gk = let g =
    [[2;4;5;4;2];
     [4;9;12;9;4];
     [5;12;15;12;5];
     [4;9;12;9;4];
     [2;4;5;4;2]] 
  in
  Array.of_list (List.map g ~f:(Array.of_list)) in
    for x = 0 to w - 1 do
      for y = 0 to h - 1 do
	let c,_ = (conv src x y ( * ) gk ~div:(159)) in
	out#set x y c;
      done
    done;  
    out      
;;     
  

(* Main canny function *)

let canny (src:rgb24) : rgb24 * int array array =
  let w = src#width in
  let h = src#height in
  let hist = let lsmat = [[(ht);(ht);(ht)];[ht;ht;ht];[ht;ht;ht]] in
	       Array.of_list (List.map lsmat ~f:(Array.of_list)) in
  let mat = Array.make_matrix (w-2) (h-2) 0 in
  let oimg = new rgb24 (w - 2) (h - 2) in
  let img,dirq,_ = sobel (gauss src) in
    for x = 1 to w - 2 do
      for y = 1 to h - 2 do
	oimg#set (x-1) (y-1) (let c = (
	match Float.to_int dirq.(x).(y) with
	|0|4 -> if (img#get x y).r < 
		     Int.max (img#get (x+1) y).r (img#get (x-1) y).r
	        then black else (img#get x y)
    |1|5 -> if (img#get x y).r < 
		     (Int.max (img#get (x+1) (y+1)).r (img#get (x-1) (y-1)).r)
	     	then black else (img#get x y)
	|2|6 -> if (img#get x y).r < 
		     Int.max (img#get x (y+1)).r (img#get x (y-1)).r
	         then black else (img#get x y)
	|3|7 ->if (img#get x y).r < 
		    Int.max (img#get (x+1) (y-1)).r (img#get (x-1) (y+1)).r
	       then black else (img#get x y)
	|_ -> black ) in if c.r > ht then (mat.(x-1).(y-1) <- 1; c) 
			 else if  c.r > lt && (let v,_ = conv src (x-1) (y-1) 
							 ( / ) hist in v.r) > 0
			 then (mat.(x-1).(y-1) <- 1; c) else black)
	               
      done
    done; oimg,mat
;;

let canny_img src = let x,_ = canny src in x;;

let canny_mat src = let _,x = canny src in x;;

let sobel_img src = let x,_,_ = sobel src in x;;

let sobel_mat src = let _,_,x = sobel src in x;;
  (* this section to make the image grayscale
   * taken from camlimage library
   *)

let monochrome img = 
  for x = 0 to img#width - 1 do
    for y = 0 to img#height - 1 do
      let rgb = img#get x y in
      let mono = Color.brightness rgb in
      img#set x y { r = mono; g = mono; b = mono; }
    done
  done; img;;
  


let find_edge img = 
  let x,_,_ = sobel (monochrome img)  in x
