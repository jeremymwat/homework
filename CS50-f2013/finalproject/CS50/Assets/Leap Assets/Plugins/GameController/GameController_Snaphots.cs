//////////////////////////////////////////////////////////////////////////
/// @file	GameController_Snapshots.cs
///
/// @author	Sean Turner (ST)
///
/// @brief	Controller snapshot support for the Unity plugin interface to the native iOS7+ GameController.framework.
/// 
/// @note	Read the Apple GameController.framework documentation for details of the underlying functionality being exposed here.
/// 
/// @note	Snapshot usage:
/// 
///			 bool 	GetGamepadSnapshot(int nController, ref GCGamepadSnapShotDataV100 snapshot)
/// 		 bool 	GetExtendedGamepadSnapshot(int nController, ref GCExtendedGamepadSnapShotDataV100 snapshot)
///
///			 snapshot.GetInputValue(GCInput eInput) : return the value of a single input in this snapshot using the GCInput enum.
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
	/************************** SNAPSHOT CLASSES ****************************/

	// Gamepad snapshot class. Mirror of the struct of the same name declared inside GameController.framework
	[StructLayout(LayoutKind.Sequential, Pack=1)]
	public class GCGamepadSnapShotDataV100
	{
	    // Standard information
	    public Int16 version; //0x0100
	    public Int16 size;    //sizeof(GCGamepadSnapShotDataV100) or larger
	    
	    // Standard gamepad data
	    // Axes in the range [-1.0, 1.0]
	    public float dpadX;
	    public float dpadY;
	    
	    // Buttons in the range [0.0, 1.0]
	    public float buttonA;
	    public float buttonB;
	    public float buttonX;
	    public float buttonY;
	    public float leftShoulder;
	    public float rightShoulder;
		
		/// @brief	Get a snapshot input value by enum.
		public float GetInputValue(GCInput eInput)
		{
			switch(eInput)
			{
				case GCInput.gpDPadXAxis: 			return(dpadX);
				case GCInput.gpDPadYAxis: 			return(dpadY);
				case GCInput.gpDPadUp: 				return(Math.Max(0.0f, dpadY));
				case GCInput.gpDPadDown: 			return(Math.Max(0.0f, -dpadY));
				case GCInput.gpDPadLeft: 			return(Math.Max(0.0f, -dpadX));
				case GCInput.gpDPadRight: 			return(Math.Max(0.0f, dpadX));
				case GCInput.gpButtonA: 			return(buttonA);
				case GCInput.gpButtonB: 			return(buttonB);
				case GCInput.gpButtonX: 			return(buttonX);
				case GCInput.gpButtonY: 			return(buttonY);
				case GCInput.gpLeftShoulder: 		return(leftShoulder);
				case GCInput.gpRightShoulder: 		return(rightShoulder);
				default: 							return(0.0f);
			}
		}
	};
	
	// ExtendedGamepad snapshot class. Mirror of the struct of the same name declared inside GameController.framework
	[StructLayout(LayoutKind.Sequential, Pack=1)]
	public class GCExtendedGamepadSnapShotDataV100
	{
	    // Standard information
	    public Int16 version; //0x0100
	    public Int16 size;    //sizeof(GCExtendedGamepadSnapShotDataV100) or larger
	    
	    // Extended gamepad data
	    // Axes in the range [-1.0, 1.0]
	    public float dpadX;
	    public float dpadY;
	    
	    // Buttons in the range [0.0, 1.0]
	    public float buttonA;
	    public float buttonB;
	    public float buttonX;
	    public float buttonY;
	    public float leftShoulder;
	    public float rightShoulder;
	
	    // Axes in the range [-1.0, 1.0]
	    public float leftThumbstickX;
	    public float leftThumbstickY;
	    public float rightThumbstickX;
	    public float rightThumbstickY;
	    
	    // Buttons in the range [0.0, 1.0]
	    public float leftTrigger;
	    public float rightTrigger;
		
		/// @brief	Get a snapshot input value by enum.
		public float GetInputValue(GCInput eInput)
		{
			switch(eInput)
			{
				case GCInput.gpDPadXAxis: 			return(dpadX);
				case GCInput.gpDPadYAxis: 			return(dpadY);
				case GCInput.gpDPadUp: 				return(Math.Max(0.0f, dpadY));
				case GCInput.gpDPadDown: 			return(Math.Max(0.0f, -dpadY));
				case GCInput.gpDPadLeft: 			return(Math.Max(0.0f, -dpadX));
				case GCInput.gpDPadRight: 			return(Math.Max(0.0f, dpadX));
				case GCInput.gpButtonA: 			return(buttonA);
				case GCInput.gpButtonB: 			return(buttonB);
				case GCInput.gpButtonX: 			return(buttonX);
				case GCInput.gpButtonY: 			return(buttonY);
				case GCInput.gpLeftShoulder: 		return(leftShoulder);
				case GCInput.gpRightShoulder: 		return(rightShoulder);
				case GCInput.exLeftThumbstickXAxis: return(leftThumbstickX);
				case GCInput.exLeftThumbstickYAxis: return(leftThumbstickY);
				case GCInput.exLeftThumbstickUp: 	return(Math.Max(0.0f, leftThumbstickY));
				case GCInput.exLeftThumbstickDown: 	return(Math.Max(0.0f, -leftThumbstickY));
				case GCInput.exLeftThumbstickLeft: 	return(Math.Max(0.0f, -leftThumbstickX));
				case GCInput.exLeftThumbstickRight: return(Math.Max(0.0f, leftThumbstickX));
				case GCInput.exRightThumbstickXAxis:return(rightThumbstickX);
				case GCInput.exRightThumbstickYAxis:return(rightThumbstickY);
				case GCInput.exRightThumbstickUp: 	return(Math.Max(0.0f, rightThumbstickY));
				case GCInput.exRightThumbstickDown: return(Math.Max(0.0f, -rightThumbstickY));
				case GCInput.exRightThumbstickLeft: return(Math.Max(0.0f, -rightThumbstickX));
				case GCInput.exRightThumbstickRight:return(Math.Max(0.0f, rightThumbstickX));
				case GCInput.exLeftTrigger: 		return(leftTrigger);
				case GCInput.exRightTrigger: 		return(rightTrigger);
				default: 							return(0.0f);
			}
		}
	};
	
	/************************** TAKING SNAPSHOTS  ***************************/
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Take a snapshot of all Gamepad input values into a provided GCGamepadSnapShotDataV100 variable.
	//////////////////////////////////////////////////////////////////////////
	public static bool GetGamepadSnapshot(int nController, ref GCGamepadSnapShotDataV100 snapshot)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
		{
			// Create a pinned GCHandle to stop the Garbage Collector moving the snapshot data during this call.
			GCHandle handle = GCHandle.Alloc(snapshot, GCHandleType.Pinned);
			bool bSuccess = _GCGetGamepadSnapshotV100(nController, handle.AddrOfPinnedObject());
			handle.Free();
			
			return( bSuccess );
		}
#endif // UNITY_IPHONE

		return(false);
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Take a snapshot of all ExtendedGamepad input values into a provided GCExtendedGamepadSnapShotDataV100 variable.
	//////////////////////////////////////////////////////////////////////////
	public static bool GetExtendedGamepadSnapshot(int nController, ref GCExtendedGamepadSnapShotDataV100 snapshot)
	{
#if UNITY_IPHONE
		if( Application.platform == RuntimePlatform.IPhonePlayer )
		{
			// Create a pinned GCHandle to stop the Garbage Collector moving the snapshot data during this call.
			GCHandle handle = GCHandle.Alloc(snapshot, GCHandleType.Pinned);
			bool bSuccess = _GCGetExtendedGamepadSnapshotV100(nController, handle.AddrOfPinnedObject());
			handle.Free();
			
			return( bSuccess );
		}
#endif // UNITY_IPHONE

		return(false);
	}
	
	/************************* NATIVE IOS METHODS ***************************/

#if UNITY_IPHONE
	// iOS native interface
	[DllImport("__Internal")]
	private static extern bool _GCGetGamepadSnapshotV100(int nController, System.IntPtr outSnapshot);
	[DllImport("__Internal")]
	private static extern bool _GCGetExtendedGamepadSnapshotV100(int nController, System.IntPtr outSnapshot);
#endif // UNITY_IPHONE
}
