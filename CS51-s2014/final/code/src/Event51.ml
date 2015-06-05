open Core.Std;;

(* A interface for events *)
module type EVENT51 =
sig
  type listener_id

  class ['a] event :
  object
    (* Adds a listener function to the event, returning a
       unique listener_id that can be used to later remove the
       listener. The function will be invoked each time
       the event is fired. There is no guarantee about
       the order in which the listeners are invoked, so the
       client should not assume a particular order. *)
    method add_listener : ('a -> unit) -> listener_id

    (* Similar to add_listener, except the function is only
       called the first time the event is fired, and then
       removed. *)
    method add_one_shot : ('a -> unit) -> listener_id

    (* For adding listeners when we don't need the id for later removal. *)
    method add_listener_ : ('a -> unit) -> unit
    method add_one_shot_ : ('a -> unit) -> unit

    (* Removes a listener identified from the event. *)
    method remove_listener : listener_id -> unit

    (* Removes all listeners from the event. *)
    method clear_listeners : unit

    (* Signal that the event has occurred. *)
    method fire : 'a -> unit
  end
end

(* A simple implementation of events. (You are not expected to
   understand this--but I bet you can.) *)
module Event51 : EVENT51 =
struct
  (* We use physical equality on unit refs to identify unique listeners *)
  type listener_id = unit ref

  (* We represent events as a mutable list of waiters, where
     a waiter is an id and a function to invoke when the event
     is fired. *)
  type 'a waiter = { id : listener_id; action : 'a -> unit }

  class ['a] event =
  object (self)
    val mutable waiters : 'a waiter list = []

    (* Add a listener to the event *)
    method add_listener action =
      let id = ref () in
      waiters <- { id; action } :: waiters;
      id

    (* Remove a listener *)
    method remove_listener i =
      waiters <- List.filter waiters ~f:(fun w -> not (phys_equal w.id i))

    (* Add a one-shot listener.  We basically add a function
     that removes itself. *)
    method add_one_shot f =
      let id = ref () in
      let action v = self#remove_listener id; f v in
      waiters <- { id; action } :: waiters;
      id

    method add_listener_ f = ignore (self#add_listener f)
    method add_one_shot_ f = ignore (self#add_one_shot f)

    method clear_listeners = waiters <- []

  (* Fire an event -- simply iterate over the waiters and invoke
     their functions on the given value. *)
    method fire v =
      List.iter waiters ~f:(fun w -> w.action v)
  end
end
