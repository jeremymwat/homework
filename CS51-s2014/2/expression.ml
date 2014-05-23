
open Core.Std ;;
open Ast ;;
open ExpressionLibrary ;;

(* define pi for testing sin etc function *)
let pi = 4.0 *. atan 1.0;;

(* TIPS FOR PROBLEM 2:
 * 1. Read the writeup.
 * 2. Use the type definitions in the ast.ml as a reference. But don't worry
 *    about expressionLibrary.ml
 * 3. Remember to test using the function "assert".
 *)

(*>* Problem 2.1 *>*)

(* contains_var : tests whether an expression contains a variable "x"
 *     Examples : contains_var (parse "x^4") = true
 *                contains_var (parse "4+3") = false *)
let rec contains_var (e:expression) : bool =
    match e with
    | Var -> true
    | Unop (_, x) -> contains_var x
    | Binop (_, y, z) -> contains_var y || contains_var z
    | Num _ -> false

;;

assert(contains_var (parse "2" ) = false);;
assert(contains_var (parse "x" ));;
assert(contains_var (parse "x^4" ));;
assert(contains_var (parse "2*x^2 + 4 * x + 43"));;
assert(contains_var (parse "sin x"));;
assert(contains_var (parse "cos 3") = false);;
assert(contains_var (parse "sin 3 * ln x / ~x"));;


(*>* Problem 2.2 *>*)

(* evaluate : evaluates an expression for a particular value of x. Don't
 *            worry about handling 'divide by zero' errors.
 *  Example : evaluate (parse "x^4 + 3") 2.0 = 19.0 *)
let rec evaluate (e:expression) (x:float) : float =
    match e with
    | Var -> x
    | Unop (u, x') ->
       (match u with
	| Sin -> sin (evaluate x' x)
	| Cos -> cos (evaluate x' x)
	| Ln -> log (evaluate x' x)
	| Neg -> ~-.(evaluate x' x))
    | Binop (b, y', z') -> 
       (match b with	
        | Add -> (evaluate y' x) +. (evaluate z' x)
        | Sub -> (evaluate y' x) -. (evaluate z' x)
        | Mul -> (evaluate y' x) *. (evaluate z' x)
        | Div -> (evaluate y' x) /. (evaluate z' x)
        | Pow -> ( ** ) (evaluate y' x) (evaluate z' x))
    | Num n -> n
;;

assert(evaluate (Num 4.) 0. = 4.);;
assert(evaluate (Var) 1. = 1.);;
assert(evaluate (parse "x + 4") 2. = 6.);;
assert(evaluate (parse "x * 4") 2. = 8.);;
assert(evaluate (parse "x / 4") 2. = 0.5);;
assert(evaluate (parse "cos ((~x / ~4) - 1) * x^2 + ~x / (2 - ln 1)") 4. =
	 14.);;
assert(evaluate (Unop(Sin,Num 0.)) 0. = 0.);;

(*>* Problem 2.3 *>*)

(* See writeup for instructions. We have pictures! *)
let rec derivative (e:expression) : expression =
    match e with
    | Num _ -> Num 0.
    | Var -> Num 1.
    | Unop (u,e1) ->
        (match u with
        | Sin -> Binop(Mul,Unop(Cos,e1),derivative e1)
        | Cos -> Binop(Mul,derivative e1,Unop(Neg,Unop(Sin,e1)))
        | Ln -> Binop(Div, derivative e1, e1)
        | Neg -> Unop(Neg,derivative e1))
    | Binop (b,e1,e2) ->
        match b with
        | Add -> Binop(Add,derivative e1,derivative e2)
        | Sub -> Binop(Sub,derivative e1,derivative e2)
        | Mul -> Binop(Add,Binop(Mul,e1,derivative e2),
                        Binop(Mul,derivative e1,e2))
        | Div -> Binop(Div,Binop(Sub,(Binop(Mul,derivative e1,e2)), 
			    Binop(Mul,e1,derivative e2)), Binop(Pow,e2,Num 2.))
        | Pow ->
            if contains_var e2
            then Binop(Mul,Binop(Pow,e1,e2),Binop(Add,
	    Binop(Mul,derivative e2,Unop(Ln,e1)),
	    Binop(Div,Binop(Mul,derivative e1,e2),e1)))
            else Binop(Mul,e2,Binop(Mul,derivative e1,
				    Binop(Pow,e1,Binop(Sub,e2,Num 1.))))
;;

(* tests if two floats are within epsilon of one another *)
let close_enough (v:float) (test:float) (epsilon:float) : bool =
  Float.abs(test -. v) < epsilon

;;

assert(evaluate(derivative (parse "x")) 0. = 1.);;
assert(evaluate(derivative (parse "1")) 42. = 0.);;
assert(evaluate(derivative (parse "cos x")) 0. = 0.);;
assert(evaluate(derivative (parse "2*x^2+x-10")) (-0.25) = 0.);;
assert(evaluate(derivative (parse "2*x^2+x-10")) 0. = 1.);;
assert(close_enough (evaluate(derivative (parse "x*sin(x^(1/(cos x))) / (ln x)")
			     ) 0.25) (-0.45175) 0.0001);;
assert(evaluate(derivative (parse "~x - 4")) 0. = (-1.));;


(* A helpful function for testing. See the writeup. *)
let checkexp strs xval =
    print_string ("Checking expression: " ^ strs ^ "\n");
    let parsed = parse strs in (
        print_string "contains variable : ";
        print_string (string_of_bool (contains_var parsed));
        print_endline " ";
        print_string "Result of evaluation: ";
        print_float (evaluate parsed xval);
        print_endline " ";
        print_string "Result of derivative: ";
        print_endline " ";
        print_string (to_string (derivative parsed));
        print_endline " "
    )
;;


(*>* Problem 2.4 *>*)

(* See writeup for instructions. *)
let rec find_zero (e:expression) (g:float) (epsilon:float) (lim:int)
    : float option =
    if lim >= 1 then find_zero e (evaluate((Binop(Sub,Num g,Binop(
		    Div,e , derivative e))))g) epsilon (lim - 1)
    else if Float.abs(evaluate e g) < epsilon then Some g else None

;;

(* tests if expression output is within epsilon of desired values for options *)
let close_enough_opt (v:float option) (test:float) (epsilon:float) : bool =
  match v with
  | Some f -> (Float.abs(test -. f) < epsilon)
  | None -> false
;;

assert(close_enough_opt (find_zero (parse "2*x+3") 1. 0.001 10) (-1.5) 0.0001);;
assert(close_enough_opt (find_zero (parse "x^2 -4") 1. 0.001 10) 2. 0.000001);;
assert(find_zero (parse "x^x")  0.0 1. 20 = None);;
assert(find_zero (parse "x^2 + 4") 0. 0.0001 20 = None);;
assert(close_enough_opt (find_zero (parse "~x^3 + 4*x")
				   0.5 0.0001 10) 0. 0.0001);;
assert(close_enough_opt (find_zero (parse "~x^3 + 4*x")
				   2.5 0.0001 10) 2. 0.0001);;
assert(close_enough_opt (find_zero (parse "~x^3 + 4*x")
				   (-2.5) 0.0001 10) (-2.) 0.0001);;
assert(close_enough_opt (find_zero (parse "sin x")
				   (-0.5) 0.0001 10) (0.) 0.0001);;
assert(close_enough_opt (find_zero (parse "ln x")
				   (0.5) 0.0001 10) (1.0) 0.0001);;


(*>* Problem 2.5 *>*)

(* Challenge problem:
 * Just leave it unimplemented if you don't want to do it.
 * See writeup for instructions. *)(*
let rec find_zero_exact (e:expression) : expression option =
    failwith "Not implemented"
;;*)


(*>* Problem 2.6 *>*)

let minutes_spent_on_part_2 : int = 180;;
