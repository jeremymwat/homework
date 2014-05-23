
open Core.Std
open Option
(* TESTING REQUIRED:
 * Ocaml provides the function "assert" which takes a bool. It does nothing if
 * the bool is true and throws an error if the bool is false.
 *
 * To develop good testing practices, we expect at least 2 tests (using assert)
 * per function that you write on this problem set. Please follow the model
 * shown in 1.1.a, putting the tests just below the function being tested.
 *)


(* TIME ADVICE:
 * Part 2 of this problem set (expression.ml) can be difficult, so be careful
 * with your time. *)

(****************************************************)
(******       1.1: Sparking your INTerest      ******)
(****************************************************)

(* Solve each problem in this part using List.map, List.fold_right, or
 * List.filter.
 *
 * See the Ocaml Core Library documentation on lists:
 * https://ocaml.janestreet.com/ocaml-core/109.60.00/doc/core/#Std.List
 *
 * A solution, even a working one, that does not use one of these
 * higher-order functions, will receive little or no credit.
 * However, if you can express your solution to
 * one particular part in terms of another function from
 * another part, you may do so.
 *
 * You MAY NOT change the definition of these
 * functions to make them recursive. *)

(*>* Problem 1.1.a *>*)

(*  negate_all : Flips the sign of each element in a list *)
let negate_all (nums : int list) : int list =
    List.map nums ~f:(fun x -> (-x))
;;

(* Unit test example. *)
assert ((negate_all [1; -2; 0]) = [-1; 2; 0]) ;;
assert ((negate_all []) = []) ;;
assert ((negate_all [-1; -2; -5]) = [1; 2; 5]) ;;
assert ((negate_all [20; 0; 3]) = [-20; 0; -3]) ;;
assert ((negate_all [1; -2; 0]) = [-1; 2; 0]) ;;


(*>* Problem 1.1.b *>*)

(*  sum : Returns the sum of the elements in the list. *)
let sum (nums:int list) : int =
   List.fold_right ~f:(+) nums ~init:0

;;

assert(sum [] = 0);;
assert(sum [1] = 1);;
assert(sum [5] = 5);;
assert(sum [(-1)] = -1);;
assert(sum [1;2;3] = 6);;
assert(sum [(-1);3;(-4)] = (-2));;
assert(sum [4;7;23;5;6;8;45;-24] = 74);;



(*>* Problem 1.1.c *>*)

(*  sum_rows : Takes a list of int lists (call an internal list a "row").
 *             Returns a one-dimensional list of ints, each int equal to the
 *             sum of the corresponding row in the input.
 *   Example : sum_rows [[1;2]; [3;4]] = [3; 7] *)
let sum_rows (rows:int list list) : int list =
  List.map rows ~f:(fun element -> List.fold_right ~f:(+) element ~init:0)
;;

assert(sum_rows [[]] = [0]);;
assert(sum_rows [] = []);;
assert(sum_rows [[1;2]; [3;4]] = [3; 7]);;
assert(sum_rows [[]; [1]; [1;2;3;4]; [(-1);(-3)]] = [0;1;10;-4]);;

(*>* Problem 1.1.d *>*)

(*  filter_odd : Retains only the odd numbers from the given list.
 *     Example : filter_odd [1;4;5;-3] = [1;5;-3]. *)
let filter_odd (nums:int list) : int list =
    List.filter ~f:(fun x -> x mod 2 <> 0) nums
;;

assert(filter_odd [] = []);;
assert(filter_odd [-3;-2;-1;0;1;2;3;4;5;6;7;8] = [-3; -1; 1; 3; 5; 7]);;
assert(filter_odd [1] = [1]);;
assert(filter_odd [2] = []);;
assert(filter_odd [1;4;5;-3] = [1;5;-3]);;

(*>* Problem 1.1.e *>*)

(*  num_occurs : Returns the number of times a given number appears in a list.
 *     Example : num_occurs 4 [1;3;4;5;4] = 2 *)
let num_occurs (n:int) (nums:int list) : int =
    List.fold_right ~f:(fun x y -> if x = n then y + 1 else y) nums ~init:0
;;

assert(num_occurs 1 [] = 0);;
assert(num_occurs 1 [1] = 1);;
assert(num_occurs 1 [2] = 0);;
assert(num_occurs 4 [1;3;4;5;4] = 2);;
assert(num_occurs 0 [0;0;0;0;0] = 5);;


(*>* Problem 1.1.f *>*)

(*  super_sum : Sums all of the numbers in a list of int lists
 *    Example : super_sum [[1;2;3];[];[5]] = 11 *)
let super_sum (nlists:int list list) : int =
  sum (sum_rows nlists)
;;

assert(super_sum [] = 0);;
assert(super_sum [[];[];[];[]] = 0);;
assert(super_sum [[1;2;3];[];[5]] = 11);;
assert(super_sum [[1]] = 1);;
assert(super_sum [[1;2;3];[10;-30;2];[5;4]] = -3);;


(*>* Problem 1.1.g *>*)

(*  filter_range : Returns a list of numbers in the input list within a
 *                 given range (inclusive), in the same order they appeared
 *                 in the input list.
 *       Example : filter_range [1;3;4;5;2] (1,3) = [1;3;2] *)
let filter_range (nums:int list) (range:int * int) : int list =
  let (lw,up) = range in
  List.filter ~f:(fun x -> x >= lw && x <= up) nums
;;

assert(filter_range [] (-1,3) = []);;
assert(filter_range [0] (1,3) = []);;
assert(filter_range [1] (1,3) = [1]);;
assert(filter_range [1;3;4;5;2] (1,3) = [1;3;2]);;
assert(filter_range [1;3;4;5;2;-3;-5;-1] (-1,3) = [1;3;2;-1]);;
assert(filter_range [1;3;4;5;2;5;4;3;1] (1,3) = [1;3;2;3;1]);;
assert(filter_range [1;3;4;5;2] (0,0) = []);;
assert(filter_range [1;3;4;5;2] (1,1) = [1]);;


(****************************************************)
(**********       1.2 Fun with Types       **********)
(****************************************************)


(*>* Problem 1.2.a *>*)

(*  floats_of_ints : Converts an int list into a list of floats *)
let floats_of_ints (nums:int list) : float list =
    List.map nums ~f:(fun x -> float x)
;;

assert(floats_of_ints [] = []);;
assert(floats_of_ints [1] = [1.]);;
assert(floats_of_ints [1;2;3;4;5] = [1.;2.;3.;4.;5.]);;
assert(floats_of_ints [(-1);(-3)] = [(-1.);(-3.)]);;


(*>* Problem 1.2.b *>*)

(*   log10s : Applies the log10 function to all members of a list of floats.
 *            The mathematical function log10 is not defined for
 *            numbers n <= 0, so undefined results should be None.
 *  Example : log10s [1.0; 10.0; -10.0] = [Some 0.; Some 1.; None] *)
let log10s (lst: float list) : float option list =
    List.map lst ~f:(fun x -> if x <= 0. then None else Some (log10 x))
;;

assert(log10s [] = []);;
assert(log10s [0.] = [None]);;
assert(log10s [(-1.)] = [None]);;
assert(log10s [10.] = [Some 1.]);;
assert(log10s [1.;10.] = [Some 0.;Some 1.]);;
assert(log10s [1.0; 10.0; -10.0] = [Some 0.; Some 1.; None]);;



(*>* Problem 1.2.c *>*)

(*  deoptionalize : Extracts values from a list of options.
 *        Example : deoptionalize [Some 3; None; Some 5; Some 10] = [3;5;10] *)
let deoptionalize (lst:'a option list) : 'a list =
  List.fold_right ~f:(fun x y -> match x with
				 | Some x -> x::y
				 | None -> y) 
		   lst ~init:[]


;;
assert(deoptionalize [] = []);;
assert(deoptionalize [None] = []);;
assert(deoptionalize [None; Some "Test"] = ["Test"]);;
assert(deoptionalize [Some 2] = [2]);;
assert(deoptionalize [Some 3; None; Some 5; Some 10] = [3;5;10]);;
assert(deoptionalize [Some 'a'; None; Some 'b'] = ['a';'b']);;



(*>* Problem 1.2.d *>*)

(*  some_sum : Sums all of the numbers in a list of int options;
 *             ignores None values *)
let some_sum (nums:int option list) : int =
    sum (deoptionalize nums)
;;
assert(some_sum [] = 0)
assert(some_sum [Some 1] = 1);;
assert(some_sum [Some 5; None] = 5);;
assert(some_sum [Some (-1)] = -1);;
assert(some_sum [Some 1;None;Some 2;Some 3] = 6);;
assert(some_sum [None] = 0);;

(*>* Problem 1.2.e *>*)

(*  mult_odds : Product of all of the odd members of a list.
 *    Example : mult_odds [1;3;0;2;-5] = -15 *)
let mult_odds (nums:int list) : int =
  List.fold_right ~f:(fun x -> if x mod 2 <> 0
			       then ( * ) x else ( * ) 1) nums ~init:1
;;

assert(mult_odds [] = 1);;
assert(mult_odds [1;3] = 3);;
assert(mult_odds [1;3;4] = 3);;
assert(mult_odds [1;3;0;2;-5] = -15);;
assert(mult_odds [4] = 1);;




(*>* Problem 1.2.f *>*)

(*  concat : Concatenates a list of lists. See the Ocaml library ref *)

(* Look upon my solution before I knew you could use the @ operator,
 ye TAs, and despair

let concat (lists:'a list list) : 'a list =
    List.fold_right ~f:(fun n m -> List.fold_right 
         ~f:(fun y z -> y::z) n ~init:m) lists ~init:[]
;;
 *)

let concat (lists:'a list list) : 'a list =
    List.fold_right ~f:(@) lists ~init:[]


assert(concat [] = []);;
assert(concat [[]] = []);;
assert(concat [['a']] = ['a']);;
assert(concat [[1]] = [1]);;
assert(concat [[1;2];[3;4]] = [1;2;3;4]);;
assert(concat [["Hello";",";" "];["world"; "!"]] =
	 ["Hello";",";" ";"world";"!"]);;



(*>* Problem 1.2.g *>*)

(* the student's name and year *)
type name = string
type year = int
type student = name * year

(*  filter_by_year : returns the names of the students in a given year
 *         Example : let students = [("Joe",2010);("Bob",2010);("Tom",2013)];;
 *                   filter_by_year students 2010 => ["Joe";"Bob"] *)
let filter_by_year (slist:student list) (yr:year) : name list =
   List.fold_right ~f:(fun (x,y) z -> if y = yr then x::z else z) slist ~init:[]
;;

assert(filter_by_year [] 2009 = []);;
assert(filter_by_year [("Bob", 2010)] 2009 = []);;
assert(filter_by_year [("Bob",2009)] 2009 = ["Bob"]);;
assert(filter_by_year [("Joe",2010);("Bob",2010);("Tom",2013)] 2010 = 
	                                             ["Joe";"Bob"]);;


(*>* Problem 1.3 *>*)

(* Please give us an honest estimate of how long this Part of the problem
 * set took you to complete.  We care about your responses and will use
 * them to help guide us in creating future assignments. *)
let minutes_spent_on_part_1 : int = 180;;
