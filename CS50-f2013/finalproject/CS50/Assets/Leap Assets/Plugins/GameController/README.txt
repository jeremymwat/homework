GameControllerUnity plugin by Hutch.
==============================================================================================================================================================================================

Welcome to the iOS 7 GameController framework plugin for Unity.

Read the Apple GameController.framework documentation for details of the underlying functionality being exposed here.
https://developer.apple.com/library/ios/documentation/ServicesDiscovery/Conceptual/GameControllerPG/Introduction/Introduction.html


WHAT'S IN THE PACKAGE:
==============================================================================================================================================================================================

Import the GameControllerUnity.unitypackage into your project and you'll find these new assets, which can be deleted if the plugin isnt needed later;

Plugins/GameController/
	GameController.cs				- main GameController plugin script supplying static function interface to the native code.
	GameController_Snapshots.ca		- supporting script to supply controller snapshot classes and functionality.
	GameControllerGUI.cs			- development utility to display a real-time controller status GUI display. Can be deleted if not needed.
	GameControllerGUI.prefab		- drop this into a scene to see the controller status GUI display. Can be deleted if not needed.
	README.txt						- this document.
Plugins/iOS/
	libGameControllerUnity.a		- native iOS library that will automatically be added to the Xcode project in the iOS build process.


API MANUAL:
==============================================================================================================================================================================================

All the following functionality will only work when compiled with Xcode5 and iOS7 SDK and above.

All other platforms will quietly do nothing and no controllers will be connected. Running on iOS versions previous to 7 will also report no controllers.


SETTING UP CONTROLLERS:
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

To connect wired (attached) controllers and start using the plugin call this from an early Awake method;

	GameController.Start();

Most apps won't need to, but if for any reason your app needs to stop controller access call;

	GameController.Stop();

To initiate a search for wireless controllers call;

	GameController.StartWirelessControllerDiscovery();
	
This process will timeout, but if your app wants to stop it early call;

	GameController.StopWirelessControllerDiscovery();
	
If your app doesnt supply a UI for choosing controller player indices (lights), you can call this to auto assign unique indices to each controller;

	GameController.AutoAssignPlayerIndices();
	
To obtain the number of connected controllers at any time call;

	int controllers = GameController.GetNumControllers();


CONTROLLER PROPERTIES:
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

To query the configuration and type of controllers that are connected use the following calls;

(NOTE: Controllers are referenced by index in the range 0 to GameController.GetNumControllers()-1.)

	string name = GameController.GetControllerVendorName(int nController); 			// returns the controller's vendor name.
	
	bool attached =	GameController.GetControllerAttachedToDevice(int nController);	// returns whether this controller is physically attached (true) or wireless (false).
	
	int index =	GameController.GetControllerPlayerIndex(int nController);			// returns this controller's player index (controller light). These persist between apps and sessions.
	
	GameController.SetControllerPlayerIndex(int nController);						// set the player index of this controller (controller light). These persist between apps and sessions.
	
	bool support = GameController.SupportsGamepad(int nController);					// returns whether the basic GamePad profile is supported by this controller (should always be true).
	
	bool support = GameController.SupportsExtendedGamepad(int nController);			// returns whether the ExtendedGamePad profile is supported by this controller.


CONTROLLER INPUT ACCESS:
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The plugin supports the 3 methods of obtaining controller data exposed by the GameController.framework;

1. Polling: 

	float value = GameController.GetInputValue(int nController, GCInput eInput); 	// returns the value of a single input on this controller using the GCInput enum.
	bool pressed = GameController.GetInputPressed(int nController, GCInput eInput); // returns whether this input is pressed down.
	
2. Callback:	

	GameController.InputValueChangedEvent += myInputValueChangedCallback;
	
	(NOTE: InputValueChangedEvent does not currently fire when DPad or Thumbstick changes occur to keep the number of events down. These should be polled.)

3. Snapshot:

	bool success = GameController.GetGamepadSnapshot(int nController, ref GCGamepadSnapShotDataV100 snapshot);
	bool success = GameController.GetExtendedGamepadSnapshot(int nController, ref GCExtendedGamepadSnapShotDataV100 snapshot);


SUPPORT:
==============================================================================================================================================================================================

Please email problems, bugs and suggestions to sean@hutchgames.com. 
I'm a full time game developer at Hutch so may not always reply immediately but I am keen to hear feedback. Sean.