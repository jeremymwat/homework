//////////////////////////////////////////////////////////////////////////
/// @file	GameController.cs
///
/// @author	Sean Turner (ST)
///
/// @brief	Unity plugin interface to the native iOS7+ GameController.framework.
/// 
/// @note	Read the Apple GameController.framework documentation for details of the underlying functionality being exposed here.
/// 
/// @note	Unity plugin usage:
/// 
/// 		PLUGIN SET UP :
/// 
/// 		 void 	Start() : call from an early Awake method in your app before the plugin can be used.
/// 		 void 	Stop() : shouldn't ever need to be called unless your app needs to stop controller access mid-session.
/// 
/// 		 void 	StartWirelessControllerDiscovery() : connect wireless controllers. ControllerDidConnect event is called for each detected.
/// 		 void 	StopWirelessControllerDiscovery() : wireless discovery will timeout, call this to stop it earlier.
///			 int 	GetNumControllers() : use this to determine the number of currently connected controllers. Updates as controllers connect and disconnect.
///			 void 	AutoAssignPlayerIndices() : helper to ensure all connected controllers are assigned a unique player index.
/// 
/// 		CONTROLLER PROPERTIES
/// 
///  		 (NOTE: Controllers are referenced by index in the range 0 to GameController.GetNumControllers-1.)
/// 
/// 		 string GetControllerVendorName(int nController) : returns the controller's vendor name.
///			 bool 	GetControllerAttachedToDevice(int nController) : returns whether this controller is physically attached (true) or wireless (false).
///			 int 	GetControllerPlayerIndex(int nController) : returns this controller's player index (controller light). These persist between apps and sessions.
///			 void 	SetControllerPlayerIndex(int nController) : set the player index of this controller (controller light). These persist between apps and sessions.
///			 bool 	SupportsGamepad(int nController) : returns whether the GamePad profile is supprted by this controller (should always be true).
///			 bool 	SupportsExtendedGamepad(int nController) : returns whether the ExtendedGamePad profile is supprted by this controller.
/// 
/// 		CONTROLLER INPUT ACCESS :
/// 
/// 		 The plugin supports the 3 methods of obtaining controller data exposed by the GameController.framework;
/// 
/// 		 1. Polling.  float GetInputValue(int nController, GCInput eInput) : return the value of a single input on this controller using the GCInput enum.
/// 		              bool 	GetInputPressed(int nController, GCInput eInput) : return whether this input is pressed down.
/// 		 2. Callback. 		InputValueChangedEvent += myInputValueChangedCallback;
///			 3. Snapshot. bool 	GetGamepadSnapshot(int nController, ref GCGamepadSnapShotDataV100 snapshot)
/// 		              bool 	GetExtendedGamepadSnapshot(int nController, ref GCExtendedGamepadSnapShotDataV100 snapshot)
///
/// 		 (NOTE: InputValueChangedEvent does not currently fire when DPad or Thumbstick changes occur to keep the number of events down. These should be polled.)
/// 
//////////////////////////////////////////////////////////////////////////

using UnityEngine;																	// Unity 			(ref http://docs.unity3d.com/Documentation/ScriptReference/index.html)
using System;																		// String / Math 	(ref http://msdn.microsoft.com/en-us/library/system.aspx)
using System.Collections;															// Queue 			(ref http://msdn.microsoft.com/en-us/library/system.collections.aspx)
using System.Collections.Generic;													// List<> 			(ref http://msdn.microsoft.com/en-us/library/system.collections.generic.aspx)
using System.Runtime.InteropServices;												// DllImport 		(ref http://msdn.microsoft.com/en-us/library/system.runtime.interopservices.aspx)

//////////////////////////////////////////////////////////////////////////
/// @brief GameController manager class.
//////////////////////////////////////////////////////////////////////////
public partial class GameController : MonoBehaviour
{
	/// @brief GCController inputs
	public enum GCInput
	{
		None					= -1,
		// Gamepad inputs
		gpDPadXAxis				= 0,
		gpDPadYAxis				= 1,
		gpDPadUp				= 2,
		gpDPadDown				= 3,
		gpDPadLeft				= 4,
		gpDPadRight				= 5,
		gpButtonA				= 6,
		gpButtonB				= 7,
		gpButtonX				= 8,
		gpButtonY				= 9,
		gpLeftShoulder			= 10,
		gpRightShoulder			= 11,
		// ExtendedGamepad inputs
		exLeftThumbstickXAxis	= 12,
		exLeftThumbstickYAxis	= 13,
		exLeftThumbstickUp		= 14,
		exLeftThumbstickDown	= 15,
		exLeftThumbstickLeft	= 16,
		exLeftThumbstickRight	= 17,
		exRightThumbstickXAxis	= 18,
		exRightThumbstickYAxis	= 19,
		exRightThumbstickUp		= 20,
		exRightThumbstickDown	= 21,
		exRightThumbstickLeft	= 22,
		exRightThumbstickRight	= 23,
		exLeftTrigger			= 24,
		exRightTrigger			= 25
	}

	/************************** CONTROLLER EVENTS ***************************/
	
	// Events external modules can listen for.
	public static event Action								WirelessControllerDiscoveryCompleteEvent;	//!< Wireless controller discovery completion event
	public static event Action<int>							ControllerDidConnectEvent;					//!< A game controller was connected with this id.
	public static event Action<int>							ControllerDidDisconnectEvent;				//!< A game controller was disconnected with this id.
	public static event Action<int>							ControllerPauseButtonEvent;					//!< A game controller's pause button was pressed.
	public static event Action<int, GCInput>				InputValueChangedEvent;						//!< A game controller's input value has changed.

	/**************************** PLUGIN SETUP ******************************/
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Start the GameController plugin. Must call this first for anything to work!
	//////////////////////////////////////////////////////////////////////////
	public static void Start()
	{
		// Already started?
		if(g_instance != null)
			return;

		// Create a GameObject+script instance to receive messages from native code.
		g_instance = new GameObject("GameController").AddComponent<GameController>();
		DontDestroyOnLoad(g_instance);
		
		// Disable screen dimming if no touches detected.
		Screen.sleepTimeout = SleepTimeout.NeverSleep;
		
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			_GCStart();
#endif // UNITY_IPHONE
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Stop the GameController plugin.
	//////////////////////////////////////////////////////////////////////////
	public static void Stop()
	{
		// Not started yet?
		if(g_instance == null)
			return;

#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			_GCStop();
#endif // UNITY_IPHONE
		
		Destroy(g_instance.gameObject);
		g_instance = null;
	}
	
	/************************ CONTROLLER DISCOVERY **************************/
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Start wireless controller discovery.
	//////////////////////////////////////////////////////////////////////////
	public static void StartWirelessControllerDiscovery()
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			_GCStartWirelessControllerDiscovery();
#endif // UNITY_IPHONE
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Stop wireless controller discovery.
	//////////////////////////////////////////////////////////////////////////
	public static void StopWirelessControllerDiscovery()
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			_GCStopWirelessControllerDiscovery();
#endif // UNITY_IPHONE
	}

	//////////////////////////////////////////////////////////////////////////
	/// @brief	Get the number of connected controllers.
	//////////////////////////////////////////////////////////////////////////
	public static int GetNumControllers()
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			return( _GCGetNumControllers() );
#endif // UNITY_IPHONE

		return(0);
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Assign unique player indices to all connected controllers.
	/// 
	/// @note	This can safely be called at start up without user input or permission as it
	/// 		will not reassign any existing player indices UNLESS they are duplicates.
	/// 
	/// 		This means player indices are not guaranteed to start at 0 or be sequential. 
	/// 		They are only guaranteed to be unique to identify players.
	//////////////////////////////////////////////////////////////////////////
	public static void AutoAssignPlayerIndices()
	{
		int nNumControllers = GetNumControllers();
		int nCon = 0;
		
		// Unassign controllers with duplicate player indices so they can be reassigned below
		for(nCon=0; nCon<nNumControllers; nCon++)
		{
			int nConIndex = GetControllerPlayerIndex(nCon);
			if(nConIndex >= 0)
			{
				for(int nConDup=nCon+1; nConDup<nNumControllers; nConDup++)
				{
					if(GetControllerPlayerIndex(nConDup) == nConIndex)
					{
						SetControllerPlayerIndex(nConDup, -1);
					}
				}
			}
		}
		
		// Assign unassigned player indices to unassigned controllers
		for(int i=0; i<nNumControllers; i++)
		{
			// Is this index already assigned to a controller?
			for(nCon=0; nCon<nNumControllers; nCon++)
			{
				if(GetControllerPlayerIndex(nCon) == i)
					break;
			}
			
			// Nope so try and assign it to an unassigned controller
			if(nCon>=nNumControllers)
			{
				for(nCon=0; nCon<nNumControllers; nCon++)
				{
					if(GetControllerPlayerIndex(nCon) < 0)
					{
						SetControllerPlayerIndex(nCon, i);
						break;
					}
				}
			}
		}
	}

	/*********************** CONTROLLER PROPERTIES **************************/
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Get this controller's vendor name.
	//////////////////////////////////////////////////////////////////////////
	public static string GetControllerVendorName(int nController)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			return( _GCGetControllerVendorName(nController) );
#endif // UNITY_IPHONE

		return(null);
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Get whether this controller is physically attached to the device.
	//////////////////////////////////////////////////////////////////////////
	public static bool GetControllerAttachedToDevice(int nController)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			return( _GCGetControllerAttachedToDevice(nController) );
#endif // UNITY_IPHONE

		return(false);
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Get this controller's player index.
	//////////////////////////////////////////////////////////////////////////
	public static int GetControllerPlayerIndex(int nController)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			return( _GCGetControllerPlayerIndex(nController) );
#endif // UNITY_IPHONE

		return(-1);
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Set this controller's player index.
	//////////////////////////////////////////////////////////////////////////
	public static void SetControllerPlayerIndex(int nController, int nPlayerIndex)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			_GCSetControllerPlayerIndex(nController, nPlayerIndex);
#endif // UNITY_IPHONE
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Does this controller support basic Gamepad inputs? (should always be true).
	//////////////////////////////////////////////////////////////////////////
	public static bool SupportsGamepad(int nController)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			return( _GCSupportsGamepad(nController) );
#endif // UNITY_IPHONE

		return(false);
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Does this controller support ExtendedGamepad inputs? (ExtendedGamepad also supports basic Gamepad inputs too)
	//////////////////////////////////////////////////////////////////////////
	public static bool SupportsExtendedGamepad(int nController)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			return( _GCSupportsExtendedGamepad(nController) );
#endif // UNITY_IPHONE

		return(false);
	}
	
	/***************************** INPUT ACCESS *****************************/

	//////////////////////////////////////////////////////////////////////////
	/// @brief	Get a controller input's value.
	//////////////////////////////////////////////////////////////////////////
	public static float GetInputValue(int nController, GCInput eInput)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			return( _GCGetInputValue(nController, (int)eInput) );
#endif // UNITY_IPHONE

		return(0.0f);
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Get whether a controller input is currently pressed down.
	//////////////////////////////////////////////////////////////////////////
	public static bool GetInputPressed(int nController, GCInput eInput)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
			return( _GCGetInputPressed(nController, (int)eInput) );
#endif // UNITY_IPHONE

		return(false);
	}

	/**************************** INTERNAL DATA *****************************/
	
	private static GameController			g_instance = null;
	
	/************************* NATIVE IOS METHODS ***************************/

#if UNITY_IPHONE
	// iOS native interface
	[DllImport("__Internal")]
	private static extern void _GCStart();
	[DllImport("__Internal")]
	private static extern void _GCStop();
	[DllImport("__Internal")]
	private static extern void _GCStartWirelessControllerDiscovery();
	[DllImport("__Internal")]
	private static extern void _GCStopWirelessControllerDiscovery();
	[DllImport("__Internal")]
	private static extern int _GCGetNumControllers();

	[DllImport("__Internal")]
	private static extern string _GCGetControllerVendorName(int nController);
	[DllImport("__Internal")]
	private static extern bool _GCGetControllerAttachedToDevice(int nController);
	[DllImport("__Internal")]
	private static extern int _GCGetControllerPlayerIndex(int nController);
	[DllImport("__Internal")]
	private static extern void _GCSetControllerPlayerIndex(int nController, int nPlayerIndex);
	[DllImport("__Internal")]
	private static extern bool _GCSupportsGamepad(int nController);
	[DllImport("__Internal")]
	private static extern bool _GCSupportsExtendedGamepad(int nController);

	[DllImport("__Internal")]
	private static extern float _GCGetInputValue(int nController, int nInput);
	[DllImport("__Internal")]
	private static extern bool _GCGetInputPressed(int nController, int nInput);
#endif // UNITY_IPHONE

	/************************* NATIVE IOS CALLBACKS *************************/
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Native code callback for completion of wireless controller discovery.
	//////////////////////////////////////////////////////////////////////////
	private void WirelessControllerDiscoveryComplete()
	{
		if(WirelessControllerDiscoveryCompleteEvent != null)
			WirelessControllerDiscoveryCompleteEvent();
	}

	//////////////////////////////////////////////////////////////////////////
	/// @brief	Native code callback for a controller connection event.
	//////////////////////////////////////////////////////////////////////////
	private void ControllerDidConnect(string sParam)
	{
		if(ControllerDidConnectEvent != null)
			ControllerDidConnectEvent(int.Parse(sParam));
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Native code callback for a controller disconnection event.
	//////////////////////////////////////////////////////////////////////////
	private void ControllerDidDisconnect(string sParam)
	{
		if(ControllerDidDisconnectEvent != null)
			ControllerDidDisconnectEvent(int.Parse(sParam));
	}

	//////////////////////////////////////////////////////////////////////////
	/// @brief	Native code callback for a controller pause button press event.
	//////////////////////////////////////////////////////////////////////////
	private void ControllerPauseHandler(string sParam)
	{
		if(ControllerPauseButtonEvent != null)
			ControllerPauseButtonEvent(int.Parse(sParam));
	}

	//////////////////////////////////////////////////////////////////////////
	/// @brief	Controller input value-changed callback.
	//////////////////////////////////////////////////////////////////////////
	private void InputValueChangedHandler(string sParam)
	{
		if(sParam == null)
			return;
		
		// Extract controller index and input enum that have changed
		string[] parts = sParam.Split(',');
		int nController = -1;
		int nInput = -1;
		
		if(parts.Length != 2)
			return;

		if(!int.TryParse(parts[0], out nController))
			return;

		if(!int.TryParse(parts[1], out nInput))
			return;
			
		// Fire event if anyone is listening
		if(InputValueChangedEvent != null)
			InputValueChangedEvent(nController, (GCInput)nInput);
	}
}
