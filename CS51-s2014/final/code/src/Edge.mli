(* Interface for edge functions *)

open OImages;;
open Images;;
(* same as sobel_img *)
val find_edge : rgb24 -> rgb24

(* returns image and matrix of the gradient direction *)
val sobel : rgb24 -> rgb24 * float array array * int array array

(* returns only image *)
val sobel_img : rgb24 -> rgb24

val sobel_mat : rgb24 -> int array array

(* applies gaussian blur, not suitable for edge finding alone *)
val gauss : rgb24 -> rgb24

(* applied full canny to img and returnst the image *)
val canny_img : rgb24 -> rgb24

(* applied canny but returns int array array of found edges *)
val canny_mat : rgb24 -> int array array

