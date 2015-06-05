open Core.Std;;
open Event51;;

(* Interface for handling user interaction in the Graphics library using
   events. *)
module type GRAPHICS_EVENTS =
sig
  class ['a] event : ['a] Event51.event

  (* Some built-in events from the Graphics package: *)
  val key_pressed  : char event
  val button_down  : (int * int) event
  val button_up    : (int * int) event
  val mouse_motion : (int * int) event
  val clock        : unit event

  (* Clears out any listeners from the above Graphics events. *)
  val clear_listeners : unit -> unit

  (* Given an initializer function f, sets up the graphics
     frame, invokes the initializer f, and then starts the
     event loop, which listens for user input and translates
     input into event firings. *)
  val run : ?frame_rate:int -> (unit -> unit) -> unit

  (* Called from a listener, terminates the event loop and
     returns from run. *)
  val terminate : unit -> 'a
end

module GraphicsEvents : GRAPHICS_EVENTS = struct
  class ['a] event = ['a] Event51.event

  (* Little hack so that I can use the same names for my
     events as Graphics does, and still get to them when
     the Graphics module is open. *)
  module E = struct
    (* Events for the primitive Graphics actions. *)
    let key_pressed : char event = new event
    let button_down : (int * int) event = new event
    let button_up : (int * int) event = new event
    let mouse_motion : (int * int) event = new event
    let clock : unit event = new event
  end

  include E

  let clear_listeners () =
    key_pressed#clear_listeners;
    button_down#clear_listeners;
    button_up#clear_listeners;
    mouse_motion#clear_listeners;
    clock#clear_listeners

  (* The Graphics event interface doesn't really provide the right
     functionality so that we can do a blocking operation and determine what
     event occurred. (For instance, we can't tell whether the mouse moved, or
     the mouse button was released.) So we use a polling approach with a
     little bit of auxilliary state to figure out what event happened, and the
     corresponding value. We then fire the appropriate high-level event. *)
  let mouse_btn_down = ref false
  let old_pos = ref (0,0)

  let read_event () =
    let open Graphics in
    (* poll for the current mouse state: *)
    let new_pos  = mouse_pos () in
    let new_down = button_down () in
    (* if mouse position changed, fire mouse_motion *)
    if new_pos <> !old_pos then
      (old_pos := new_pos;
       mouse_motion#fire new_pos);
    (* if keys were pressed, fire key_pressed for each *)
    while key_pressed () do E.key_pressed#fire (read_key ()) done;
    (* if the old state of the mouse button is different than the current
       state, fire button_down or button_up as appropriate *)
    if !mouse_btn_down <> new_down then
      (mouse_btn_down := new_down;
       let e = if new_down then E.button_down else E.button_up in
       e#fire new_pos);
    (* finally, fire the clock event *)
    clock#fire ()

  (* Helper for restarting interrupted system calls (OY) *)
  let rec restart f arg =
    try f arg
    with Unix.Unix_error (Unix.EINTR, _, _) -> restart f arg

  (* Our basic event loop just calls read_event, which fires the appropriate
     events, then synchronizes the shadow graphics buffer with the screen,
     and then loops again. *)
  let rec event_loop frame_rate =
    read_event ();
    Graphics.synchronize ();
    restart Thread.delay (1.0 /. Float.of_int frame_rate);
    event_loop frame_rate

  (* Users can break out of event loop by calling the terminate function *)
  exception Terminate
  let terminate () = raise Terminate

  (* Run is used to run a graphics app. We clear out all old event handlers,
     open the graphics page, call the user's init function (which typically
     installs listeners for the events) and then enter the event loop. If
     the user calls terminate within the event loop, then the exception
     Terminated will be raised and cause the loop to be terminated. *)
  let run ?(frame_rate : int = 30) init =
    try
      Graphics.open_graph "";
      Graphics.auto_synchronize false;
      init ();
      event_loop frame_rate
    with e ->
      Graphics.auto_synchronize true;
      Graphics.close_graph ();
      match e with
      | Terminate -> print_endline "Terminating."
      | _ -> raise e
end
