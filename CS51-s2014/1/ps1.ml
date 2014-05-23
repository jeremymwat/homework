(*** CS 51 Problem Set 1 ***)
(*** January 31, 2014 ***)
(*** YOUR NAME HERE ***)

(* Open up the library we'll be using in this course *)
open Core.Std

(* Problem 1 - Fill in types:
 * Replace each ??? with the appropriate type of the corresponding expression.
 * Be sure to remove the comments from each subproblem and to type check it
 * before submission. *)

(*>* Problem 1a *>*)

let prob1a : string = let greet y = "Hello " ^ y in greet "World!";;


(*>* Problem 1b *>*)

let prob1b : int option list = [Some 4; Some 2; None; Some 3];;


(*>* Problem 1c *>*)

let prob1c : ('a option * float option) * bool = ((None, Some 42.0), true);;



(* Explain in a comment why the following will not type check,
   and provide a fix *)

(*>* Problem 1d *>*)
(* The type as is will make a tuple of a string and an int list, rather   
 * than a list of string and integer tuples (string * int) list  *)
let prob1d : (string * int) list = [("CS", 51); ("CS", 50)];;


(*>* Problem 1e *>*)
(* you can't compare in int and float like the definition of compare.
 * adding a period to make the 4 a float fixes the problem   *) 
let prob1e : int =
  let compare (x,y) = x < y in
  if compare (4., 3.9) then 4 else 2;;


(*>* Problem 1f *>*)
(* The tuple should be of type (string * int option) list, and you 
 * would need to add a Some before each int. Alternatively you
 * could wrap quotes around each int to make it a string, but you
 * would still need a Some in order to be a proper option type*)

let prob1f : (string * int option) list =
  [("January", None); ("February", Some 1); ("March", None); ("April", None);
   ("May", None); ("June", Some 1); ("July", None); ("August", None);
   ("September",Some 3); ("October",Some 1); ("November",Some 2);
   ("December", Some 3)] ;;




(* Problem 2 - Write the following functions *)
(* For each subproblem, you must implement a given function and corresponding
 * unit tests (i.e. assert expressions). You are provided a high level
 * description as well as a prototype of the function you must implement. *)

(*>* Problem 2a *>*)

(* `reversed lst` should return true if the integers in lst are in
 * decreasing order. The empty list is considered to be reversed. Consecutive
 * elements can be equal in a reversed list. *)

(* Here is its prototype/signature: *)
(* reversed : int list -> bool *)

(* Implement reversed below, and be sure to write tests for it (see 2b for
 * examples of tests). *)


let rec reversed_lst (lst : int list) : bool = 
    match lst with
    | [] | _ :: [] -> true
    | x1 :: x2 :: tl -> x1 >= x2 && reversed_lst (x2 :: tl)

 (*if x1 >= x2 then reversed_lst (x2 :: tl) else false*)

assert( reversed_lst [1;2;3] = false);;
assert( reversed_lst [] = true);;
assert( reversed_lst [1] = true);;
assert( reversed_lst [-3;3;2;1] = false);;
assert( reversed_lst [-1] = true);;
assert( reversed_lst [-3;-3;-2;1] = false);;
assert( reversed_lst [-1;-3;-4] = true);;


(*>* Problem 2b *>*)

(* merge takes two integer lists, each sorted in increasing order,
 and returns a single merged list in sorted order. For example:

merge [1;3;5] [2;4;6];;
- : int list = [1; 2; 3; 4; 5; 6]
merge [1;3;5] [2;4;6;12];;
- : int list = [1; 2; 3; 4; 5; 6; 12]
merge [1;3;5;700;702] [2;4;6;12];;
- : int list = [1; 2; 3; 4; 5; 6; 12; 700; 702]

*)

(* The type signature for merge is as follows: *)
(* merge : int list -> int list -> int list *)


let rec merge (lst1 : int list) (lst2 : int list) : int list =
  match lst1,lst2 with
  | h1::t1, h2::t2 -> if h1 <= h2 then h1::merge t1 (h2::t2) else
		         h2::merge (h1::t1) t2
  | [],l2 -> l2
  | l1,[] -> l1


(* sample tests *)
<<<<<<< HEAD
assert ((merge [1;2;3] [4;5;6;7]) = [1;2;3;4;5;6;7]);;
assert ((merge [4;5;6;7] [1;2;3]) = [1;2;3;4;5;6;7]);;
assert ((merge [4;5;6;7] [1;2;3]) = [1;2;3;4;5;6;7]);;
assert ((merge [2;2;2;2] [1;2;3]) = [1;2;2;2;2;2;3]);;
assert ((merge [1;2] [1;2]) = [1;1;2;2]);;
assert ((merge [-1;2;3;100] [-1;5;1001]) = [-1;-1;2;3;5;100;1001]);;
assert ((merge [] []) = []);;
assert ((merge [1] []) = [1]);;
assert ((merge [] [-1]) = [-1]);;
assert ((merge [1] [-1]) = [-1;1]);;
=======
let () = assert ((merge [1;2;3] [4;5;6;7]) = [1;2;3;4;5;6;7]);;
let () = assert ((merge [4;5;6;7] [1;2;3]) = [1;2;3;4;5;6;7]);;
let () = assert ((merge [4;5;6;7] [1;2;3]) = [1;2;3;4;5;6;7]);;
let () = assert ((merge [2;2;2;2] [1;2;3]) = [1;2;2;2;2;2;3]);;
let () = assert ((merge [1;2] [1;2]) = [1;1;2;2]);;
let () = assert ((merge [-1;2;3;100] [-1;5;1001]) = [-1;-1;2;3;5;100;1001]);;
let () = assert ((merge [] []) = []);;
let () = assert ((merge [1] []) = [1]);;
let () = assert ((merge [] [-1]) = [-1]);;
let () = assert ((merge [1] [-1]) = [-1;1]);;
*)
>>>>>>> 1d6d2e914689175011c3b67fc9d70408f5aa68e1


(*>* Problem 2c *>*)
(* unzip should be a function which, given a list of pairs, returns a
 * pair of lists, the first of which contains each first element of
 * each pair, and the second of which contains each second element.
 * The returned lists should have the elements in the order in which
 * they appeared in the input. So, for instance:

unzip [(1,2);(3,4);(5,6)];;
- : int list * int list = ([1;3;5],[2;4;6])

*)


(* The type signature for unzip is as follows: *)
(* unzip : (int * int) list -> int list * int list) *)
let rec unzip (lst : (int * int) list) : int list * int list =
  match lst with
  | [] -> ([],[])
  | (hd1,hd2)::tl -> let (l1,l2) = unzip tl in (hd1::l1,hd2::l2)

assert(unzip [(1,2);(3,4);(5,6)] = ([1;3;5],[2;4;6]));;
assert(unzip [] = ([],[]));;
assert(unzip [(1,2)] = ([1],[2]));;
assert(unzip [(1,2);(3,4);(5,6);(7,8);(9,10);(-1,0)] = ([1; 3; 5; 7; 9; -1],
							[2; 4; 6; 8; 10; 0]));;

(*>* Problem 2d *>*)

(* `variance lst` returns None if lst has fewer than 2 floats, and
 * Some of the variance of the floats in lst otherwise.  Recall that
 * the variance of a sequence of numbers is 1/(n-1) * sum (x_i-m)^2,
 * where a^2 means a squared, and m is the arithmetic mean of the list
 * (sum of list / length of list). For example:

variance [1.0; 2.0; 3.0; 4.0; 5.0];;
- : int option = Some 2.5
variance [1.0];;
- : int option = None

 * Remember to use the floating point version of the arithmetic
 * operators when operating on floats (+. *., etc). The "float"
 * function can cast an int to a float. *)

(* helper function to get length of list*)
let rec list_length (flist : float list) : float =
  match flist with
  | [] -> 0.
  | _::tl -> 1. +. list_length tl
;;

(* helper function to sum a list of floats*)
let rec fsum (flist : float list) : float = 
  match flist with
  | [] -> 0.
  | hd::tl-> hd +. fsum tl
;;

(* helper function to get average of a list of floats *)
let float_avg (flist: float list) : float =
  fsum flist /. list_length flist

;;

(* helper to square floats *)
let fsquare (x : float) : float =
  x *. x
;;

(* helper to get sum of a float minus a float squared *)
let rec sum_sq_f (flist : float list) (mean : float) : float =
  match flist with 
  | [] -> 0.
  | hd::tl -> fsquare (hd -. mean) +. sum_sq_f tl mean

;;

(* variance : float list -> float option *)
let variance (flist : float list) : float option =
  let length = list_length flist in
  let avg = float_avg flist in
  if length <= 2. then None else Some (1. /. (length -. 1.) *.
					       sum_sq_f flist (avg))
  
;;


assert(variance [1.0; 2.0; 3.0; 4.0; 5.0] = Some 2.5);;
assert(variance [] = None);;
assert(variance [4.] = None);;
assert(variance [1.;2.] = None);;
assert(variance [1.; 0.; 5.; (-6.0);(-3.0)] = Some 17.3);;


(*>* Problem 2e *>*)

(* few_divisors n m should return true if n has fewer than m divisors,
 * (including 1 and n) and false otherwise. Note that this is *not* the
 * same as n having fewer divisors than m:

few_divisors 17 3;;
- : bool = true
few_divisors 4 3;;
- : bool = false
few_divisors 4 4;;
- : bool = true

 * Do not worry about negative integers at all. We will not test
 * your code using negative values for n and m, and do not
 * consider negative integers for divisors (e.g. don't worry about
 * -2 being a divisor of 4) *)

(* The type signature for few_divisors is: *)
(* few_divisors : int -> int -> bool *)
let few_divisors (n : int) (m : int) : bool =
  let rec div_count (dn : int) (dv: int) = 
    if dv <= 0 then 0 else 
      if dn mod dv = 0 then 1 + div_count dn (dv - 1) 
      else div_count dn (dv - 1)
  in div_count n n < m
    

;;

assert(few_divisors 17 3 = true);;
assert(few_divisors 4 3 = false);;
assert(few_divisors 0 0 = false);;
assert(few_divisors 1 1 = false);;
assert(few_divisors 3245 9 = true);;
assert(few_divisors 42 7 = false);;
assert(few_divisors 1024 11 = false);;


(*>* Problem 2f *>*)

(* `concat_list sep lst` returns one big string with all the string
 * elements of lst concatenated together, but separated by the string
 * sep. Here are some example tests:

concat_list ", " ["Greg"; "Anna"; "David"];;
- : string = "Greg, Anna, David"
concat_list "..." ["Moo"; "Baaa"; "Quack"];;
- : string = "Moo...Baaa...Quack"
concat_list ", " [];;
- : string = ""
concat_list ", " ["Moo"];;
- : string = "Moo"

*)

(* The type signature for concat_list is: *)
(* concat_list : string -> string list -> string *)

let rec concat_list (str_add : string) (str_list : string list) : string =
 match str_list with
 | [] -> ""
 | hd::[] -> hd
 | hd::tl -> hd ^ str_add ^ concat_list str_add tl

;;

assert(concat_list ", " ["Greg"; "Anna"; "David"] ="Greg, Anna, David" );;
assert(concat_list "..." ["Moo"; "Baaa"; "Quack"] = "Moo...Baaa...Quack" );;
assert(concat_list ", " [] = "") ;;
assert(concat_list ", " ["Moo"] = "Moo");;
assert(concat_list "my name is " ["Hi! ";"- what ? - ";"- who? - ";"slim shady"]
 = "Hi! my name is - what ? - my name is - who? - my name is slim shady");;


(*>* Problem 2g *>*)

(* One way to compress a list of characters is to use run-length encoding.
 * The basic idea is that whenever we have repeated characters in a list
 * such as ['a';'a';'a';'a';'a';'b';'b';'b';'c';'d';'d';'d';'d'] we can
 * (sometimes) represent the same information more compactly as a list
 * of pairs like [(5,'a');(3,'b');(1,'c');(4,'d')].  Here, the numbers
 * represent how many times the character is repeated.  For example,
 * the first character in the string is 'a' and it is repeated 5 times,
 * followed by 3 occurrences of the character 'b', followed by one 'c',
 * and finally 4 copies of 'd'.
 *
 * Write a function to_run_length that converts a list of characters into
 * the run-length encoding, and then write a function from_run_length
 * that converts back. Writing both functions will make it easier to
 * test that you've gotten them right. *)

(* The type signatures for to_run_length and from_run_length are: *)
(* to_run_length : char list -> (int * char) list *)
(* from_run_length : (int * char) list -> char list *)

let rec to_run_length (tlst : char list) : (int * char) list =
  match tlst with
  | [] -> []
  | [hd] -> [(1,hd)]
  | hd1::tl1 -> let rtlst = (to_run_length tl1) in
	       match rtlst with
               | [] -> []
	       | (x,y)::tl2 -> if y = hd1  then (x+1, y)::tl2
			       else (1, hd1)::(x, y)::tl2
;;


assert(to_run_length [] = []);;
assert(to_run_length ['a'] = [(1,'a')]);;
assert(to_run_length ['a';'a'] = [(2,'a')]);;
assert(to_run_length ['a';'b'] = [(1,'a');(1,'b')]);;
assert(to_run_length ['a';'b';'c'] = [(1,'a');(1,'b');(1,'c')]);;
assert(to_run_length ['a';'a';'b';'a';'c';'c';'c'] =[(2,'a');(1,'b');
						     (1,'a');(3,'c')]);;
assert(to_run_length ['a';'b';'c';'a';'b';'c';'a';'b';'c'] = 
    [(1,'a');(1,'b');(1,'c');(1,'a');(1,'b');(1,'c');(1,'a');(1,'b');(1,'c')]);;


let rec from_run_length (lst : (int * char) list) : char list =
  match lst with
  | [] -> []
  | (0,_)::tl -> from_run_length tl
  | (h1, h2)::tl -> h2::from_run_length((h1-1,h2)::tl)
;;

assert(from_run_length [] = []);;
assert(from_run_length [(1,'a')] = ['a']);;
assert(from_run_length [(2,'a')] = ['a';'a']);;
assert(from_run_length [(2,'a');(1,'b');(1,'a');(3,'c')] =
                             ['a';'a';'b';'a';'c';'c';'c']);;

(* doing some double testing *)

assert(from_run_length (to_run_length ['a']) = ['a']);;
assert(from_run_length (to_run_length ['a';'a']) = ['a';'a']);;
assert(from_run_length (to_run_length['a';'a';'b';'a';'c';'c';'c'])
                                   = ['a';'a';'b';'a';'c';'c';'c']);;



(*>* Problem 3 *>*)

(* Challenge!

 * permutations lst should return a list containing every
 * permutation of lst. For example, one correct answer to
 * permutations [1; 2; 3] is
 * [[1; 2; 3]; [2; 1; 3]; [2; 3; 1]; [1; 3; 2]; [3; 1; 2]; [3; 2; 1]].

 * It doesn't matter what order the permutations appear in the returned list.
 * Note that if the input list is of length n then the answer should be of
 * length n!.

 * Hint:
 * One way to do this is to write an auxiliary function,
 * interleave : int -> int list -> int list list,
 * that yields all interleavings of its first argument into its second:
 * interleave 1 [2;3] = [ [1;2;3]; [2;1;3]; [2;3;1] ].
 * You may also find occasion for the library functions
 * List.map and List.concat. *)

(* The type signature for permuations is: *)
(* permutations : int list -> int list list *)
(*
let rec interleave (inter : int) (lst : int list) : int list list = 
  match lst with
 *)
