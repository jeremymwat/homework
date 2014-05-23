(* NAMES:
 *
 * Partner 1's name: Jeremy Watson
 * Partner 1's code.seas account: jeremywatson
 *
 * (Leave blank if you are working alone)
 * Partner 2's name: ______
 * Partner 2's code.seas account: _______
 *)

open Core.Std

(* Consider this mutable list type. *)
type 'a mlist = Nil | Cons of 'a * (('a mlist) ref)

(*>* Problem 1.1 *>*)
(* Write a function has_cycle that returns whether a mutable list has a cycle.
 * You may want a recursive helper function. Don't worry about space usage. *)
let has_cycle (lst : 'a mlist) : bool =
  let ref_list = ref lst in
  let rec has_cycle_rec (list : 'a mlist ref)	(listrefs :  'a mlist ref list) : bool =
    let listrefs = list::listrefs in
    match !list with
    | Nil -> false
    | Cons(_, next) -> if List.exists listrefs ~f:(fun x -> phys_equal !x !next)
		       then true else has_cycle_rec next listrefs
  in has_cycle_rec ref_list []

(* Some mutable lists for testing. *)
let list1a = Cons(2, ref Nil)
let list1b = Cons(2, ref list1a)
let list1 = Cons(1, ref list1b)

let reflist = ref (Cons(2, ref Nil))
let list2 = Cons(1, ref (Cons (2, reflist)))
let _ = reflist := list2

let reflist2 = ref (Cons(1, ref Nil))
let list3 = Cons(1, reflist2)
let _ = reflist2 := list3

let list4 = Cons(1, ref (Cons (2, ref Nil)))

assert(has_cycle list1 = false);;
assert(has_cycle list2 = true);;
assert(has_cycle list3 = true);;
assert(has_cycle list4 = false);;

(*>* Problem 1.2 *>*)
(* Write a function flatten that flattens a list (removes its cycles if it
 * has any) destructively. Again, you may want a recursive helper function and
 * you shouldn't worry about space. *)
let flatten (lst : 'a mlist) : unit =
  let ref_list = ref lst in
  let rec flatten_rec (list : 'a mlist ref)
		      (listrefs : 'a mlist ref list) : unit =
    let listrefs = list::listrefs in
    match !list with
    | Nil -> ()
    | Cons(_, next) -> if List.exists listrefs ~f:(fun x -> phys_equal !x !next)
		       then next := Nil
		       else flatten_rec next listrefs

  in flatten_rec ref_list []


let list1af = Cons(2, ref Nil)
let list1bf = Cons(2, ref list1af)
let list1f = Cons(1, ref list1bf)

let reflistf = ref (Cons(2, ref Nil))
let list2f = Cons(1, ref (Cons (2, reflistf)))
let _ = reflistf := list2f

let reflist2f = ref (Cons(1, ref Nil))
let list3f = Cons(1, reflist2f)
let _ = reflist2f := list3f

let list4f = Cons(1, ref (Cons (2, ref Nil)))

let _ = flatten list1f
let _ = flatten list2f
let _ = flatten list3f
let _ = flatten list4f

assert(has_cycle list1f = false);;
assert(has_cycle list2f = false);;
assert(has_cycle list3f = false);;
assert(has_cycle list4f = false);;


(*>* Problem 1.3 *>*)
(* Write mlength, which finds the number of nodes in a mutable list. *)
let mlength (lst : 'a mlist) : int =
    let ref_list = ref lst in
  let rec counter_rec (list : 'a mlist ref)
		      (listrefs : 'a mlist ref list) (counter : int) : int =
    let listrefs = list::listrefs in
    match !list with
    | Nil -> counter
    | Cons(_, next) -> if List.exists listrefs ~f:(fun x -> phys_equal !x !next)
		       then counter + 1
		       else counter_rec next listrefs (counter + 1)

  in counter_rec ref_list [] 0


assert(mlength list1 = 3);;
assert(mlength list2 = 2);;
assert(mlength list3 = 1);;
assert(mlength list4 = 2);;


(*>* Problem 1.4 *>*)
(* Please give us an honest estimate of how long this part took
 * you to complete.  We care about your responses and will use
 * them to help guide us in creating future assignments. *)
let minutes_spent : int = 80
