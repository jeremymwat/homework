open Core.Std

(* Definitions for sets. *)

exception TODO

(* An interface for set modules *)
module type SET =
sig
  type elt  (* type of elements in the set *)
  type set  (* abstract type for the set *)

  val empty : set

  val is_empty : set -> bool

  val insert : elt -> set -> set

  (* same as insert x empty *)
  val singleton : elt -> set

  val union : set -> set -> set
  val intersect : set -> set -> set

  (* remove an element from the set -- if the
   * element isn't present, does nothing. *)
  val remove : elt -> set -> set

  (* returns true iff the element is in the set *)
  val member : set -> elt -> bool

  (* chooses some member from the set, removes it
   * and returns that element plus the new set.
   * If the set is empty, returns None. *)
  val choose : set -> (elt * set) option

  (* fold a function across the elements of the set
   * in some unspecified order. *)
  val fold : (elt -> 'a -> 'a) -> 'a -> set -> 'a

  (* functions to convert our types to a string. useful for debugging. *)
  val string_of_set : set -> string
  val string_of_elt : elt -> string

  (* runs our tests. See TESTING EXPLANATION *)
  val run_tests : unit -> unit
end



(* parameter to Set modules -- we must pass in some
 * type for the elements of a set, a comparison
 * function, and a way to stringify it.
 *)
module type COMPARABLE =
sig
  type t
  val compare : t -> t -> Ordering.t
  val string_of_t : t -> string

  (* The functions below are used for testing. See TESTING
   * EXPLANATION *)

  (* Generate a value of type t. The same t is always returned *)
  val gen : unit -> t

  (* Generate a random value of type t. *)
  val gen_random : unit -> t

  (* Generate a t greater than the argument. *)
  val gen_gt : t -> unit -> t

  (* Generate a t less than the argument. *)
  val gen_lt : t -> unit -> t

  (* Generate a t between the two arguments. Return None if no such
   * t exists. *)
  val gen_between : t -> t -> unit -> t option
end



(* An example implementation of our COMPARABLE signature. Use this
 * struct for testing. *)
module IntComparable : COMPARABLE =
struct
  open Order
  type t = int
  let compare x y = if x < y then Less else if x > y then Greater else Equal
  let string_of_t = string_of_int
  let gen () = 0
  let gen_random =
    let _ = Random.self_init () in
    (fun () -> Random.int 10000)
  let gen_gt x () = x + 1
  let gen_lt x () = x - 1
  let gen_between x y () =
    let (lower, higher) = (min x y, max x y) in
    if higher - lower < 2 then None else Some (higher - 1)
end



(* A simple, list-based implementation of sets. *)
module ListSet(C: COMPARABLE) : (SET with type elt = C.t) =
struct
  open Order
  type elt = C.t
  type set = elt list

  (* INVARIANT: sorted, no duplicates *)
  let empty = []
  let is_empty xs =
    match xs with
      | [] -> true
      | _ -> false
  let singleton x = [x]
  let rec insert x xs =
    match xs with
      | [] -> [x]
      | y::ys -> (match C.compare x y with
          | Greater -> y::(insert x ys)
          | Equal -> xs
          | Less -> x::xs)

  let union xs ys = List.fold_right xs ~f:insert ~init:ys
  let rec remove y xs =
    match xs with
      | [] -> []
      | x::xs1 -> (match C.compare y x with
          | Equal -> xs1
          | Less -> xs
          | Greater -> x::(remove y xs1))

  let rec intersect xs ys =
    match xs, ys with
      | [], _ -> []
      | _, [] -> []
      | xh::xt, yh::yt -> (match C.compare xh yh with
          | Equal -> xh::(intersect xt yt)
          | Less -> intersect xt ys
          | Greater -> intersect xs yt)

  let rec member xs x =
    match xs with
      | [] -> false
      | y::ys -> (match C.compare x y with
          | Equal -> true
          | Greater -> member ys x
          | Less -> false)

  let choose xs =
    match xs with
      | [] -> None
      | x::rest -> Some (x,rest)
  let fold f e = List.fold_left ~f:(fun a x -> f x a) ~init:e

  let string_of_elt = C.string_of_t
  let string_of_set (s: set) : string =
    let f = (fun y e -> y ^ "; " ^ C.string_of_t e) in
    "set([" ^ (List.fold_left s ~f:f ~init:"") ^ "])"


  (****************************************************************)
  (* Tests for our ListSet functor                                *)
  (* These are just examples of tests, your tests should be a lot *)
  (* more thorough than these.                                    *)
  (****************************************************************)

  (* adds a list of (key,value) pairs in left-to-right order *)
  let insert_list (d: set) (lst: elt list) : set =
    List.fold_left lst ~f:(fun r k -> insert k r) ~init:d

  let rec generate_random_list (size: int) : elt list =
    if size <= 0 then []
    else (C.gen_random()) :: (generate_random_list (size - 1))

  let test_insert () =
    let elts = generate_random_list 100 in
    let s1 = insert_list empty elts in
    List.iter elts ~f:(fun k -> assert(member s1 k)) ;
    ()

  let test_remove () =
    let elts = generate_random_list 100 in
    let s1 = insert_list empty elts in
    let s2 = List.fold_right elts ~f:(fun k r -> remove k r) ~init:s1 in
    List.iter elts ~f:(fun k -> assert(not (member s2 k))) ;
    ()

  let test_union () =
    ()

  let test_intersect () =
    ()

  let test_member () =
    ()

  let test_choose () =
    ()

  let test_fold () =
    ()

  let test_is_empty () =
    ()

  let test_singleton () =
    ()

  let run_tests () =
    test_insert () ;
    test_remove () ;
    test_union () ;
    test_intersect () ;
    test_member () ;
    test_choose () ;
    test_fold () ;
    test_is_empty () ;
    test_singleton () ;
    ()

end


(******************************************************************)
(* DictSet: a functor that creates a SET by calling our           *)
(* Dict.Make functor                                              *)
(******************************************************************)

module DictSet(C : COMPARABLE) : (SET with type elt = C.t) =
struct
  module D = Dict.Make(
    struct
      type key = C.t
      type value = unit
      let compare = C.compare
      let string_of_key = C.string_of_t
      let string_of_value _ = "unit"
      let gen_key = C.gen
      let gen_key_gt x () = C.gen_gt x ()
      let gen_key_lt x () = C.gen_lt x ()
      let gen_key_random () = C.gen_random ()
      let gen_key_between x y () = C.gen_between x y ()
      let gen_value () = ()
      let gen_pair () = (gen_key(),gen_value())
  end)

  type elt = D.key
  type set = D.dict

  let empty = D.empty

  let is_empty x = x = D.empty

  let insert y x = D.insert x y ()

  let singleton x = insert x empty

  let union xset yset = D.fold (fun k _ e -> insert k e) xset yset

  let intersect xset yset = 
    D.fold (fun x _ i -> if (D.member xset x) then (D.insert i x ()) 
			 else i) empty yset 
  let remove y xset = D.remove xset y
  
  let member xset y = D.member xset y
  
  let choose xset = 
    match D.choose xset with
    | None -> None 
    | Some (z,_,zset) -> Some (z,zset)

  let fold f = D.fold (fun x _ -> f x)


  (* implement the rest of the functions in the signature! *)

  let string_of_elt = D.string_of_key
  let string_of_set s = D.string_of_dict s

  (****************************************************************)
  (* Tests for our DictSet functor                                *)
  (* Use the tests from the ListSet functor to see how you should *)
  (* write tests. However, you must write a lot more              *)
  (* comprehensive tests to test ALL your functions.              *)
  (****************************************************************)

  (* add your test functions to run_tests *)
(*  let run_tests () =
    () *)


  let insert_list (d: set) (lst: elt list) : set =
    List.fold_left lst ~f:(fun r k -> insert k r) ~init:d


  let rec generate_random_list (size: int) : elt list =
    if size <= 0 then []
    else (C.gen_random()) :: (generate_random_list (size - 1))


  let test_insert () =
    let elts = generate_random_list 100 in
    let s1 = insert_list empty elts in
    List.iter elts ~f:(fun k -> assert(member s1 k)) ;
    ()

  let test_remove () =
    let elts = generate_random_list 100 in
    let s1 = insert_list empty elts in
    let s2 = List.fold_right elts ~f:(fun k r -> remove k r) ~init:s1 in
    List.iter elts ~f:(fun k -> assert(not (member s2 k))) ;
    ()

  let test_union () = 
    let elts = generate_random_list 10 in
    let s1 = insert_list empty elts in
    let u1 = union s1 s1 in
    let s2 = List.fold_right elts ~f:(fun k r -> remove k r) ~init:u1 in
    let _ = Printf.printf "\nunion test: %s" (string_of_set u1) in
    let _ = Printf.printf "\nunion test: %s" (string_of_set s2) in
    assert(is_empty s2) ;
    ()

  let test_union2 () = 
    let elts1 = generate_random_list 100 in
    let elts2 = generate_random_list 100 in
    let s1 = insert_list empty elts1 in
    let s2 = insert_list empty elts2 in
    let u1 = union s1 s2 in
    let uelts = List.concat [elts1;elts2] in
    List.iter uelts ~f:(fun k -> assert(member u1 k)) ;


    ()



  let test_intersect () =
     let elts1 = generate_random_list 100 in
    let elts2 = generate_random_list 100 in
    let s1 = insert_list empty elts1 in
    let s2 = insert_list empty elts2 in
    let interset = intersect s1 s2 in
    let interelts = List.filter elts1 ~f:(List.mem elts2) in
    let interset2 = List.fold_right interelts ~f:(fun k r -> remove k r)
				    ~init:interset in
    assert(is_empty interset2) ; ()

(* already kind of tested in insert, slightly different test here *)
  let test_member () = 
    let elts = generate_random_list 100 in
    let s1 = insert_list empty elts in
    let ranelt = match elts with
                 | [] -> failwith "bad generation"
		 | hd::_ -> hd 
    in
    let s2 = remove ranelt s1 in
    assert(member s1 ranelt && not(member s2 ranelt)) ;
  
    ()

  let test_choose () =
    let elts = generate_random_list 100 in
    let s1 = insert_list empty elts in
    let celt,cset = match choose s1 with
                 | None -> failwith "bad generation"
		 | Some (x,y) -> x,y
    in
    assert(member s1 celt && not(member cset celt)) ;
    ()

  let test_fold () =
    let elts = generate_random_list 100 in
    let s1 = insert_list empty elts in
    assert(is_empty(fold (remove) s1 s1));
    ()

  let test_is_empty () =
    let elts = generate_random_list 100 in
    let s1 = insert_list empty elts in
    let emptyset = empty in
    assert(is_empty emptyset && not(is_empty s1));
    ()

  let test_singleton () = 
    let elt1 = C.gen_random() in
    let singleset = singleton elt1 in

    assert (member singleset elt1 && is_empty(remove elt1 singleset));
    ()
    

  let run_tests () =
    test_insert () ;
    test_remove () ;
    test_union () ;
    test_union2 () ;
    test_intersect () ;
    test_member () ;
    test_choose () ;
    test_fold () ;
    test_is_empty () ;
    test_singleton () ;
    ()










end




(******************************************************************)
(* Run our tests.                                                 *)
(******************************************************************)

(* Create a set of ints using our ListSet functor. *)
module IntListSet = ListSet(IntComparable) ;;
IntListSet.run_tests();;

(* Create a set of ints using our DictSet functor
 *
 * Uncomment out the lines below when you are ready to test your
 * 2-3 dict set implementation *)

module IntDictSet = DictSet(IntComparable) ;;
IntDictSet.run_tests();;



(******************************************************************)
(* Make: a functor that creates a SET by calling our              *)
(* ListSet or DictSet functors                                    *)
(******************************************************************)
module Make(C : COMPARABLE) : (SET with type elt = C.t) =
  (* Change this line to use our dictionary implementation when your are
   * finished. *)
(*  ListSet (C) *)
  (* *) DictSet (C) (* *)

