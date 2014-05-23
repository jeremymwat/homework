//////////////////////////////////////////////////////////////////////////
/// @file	GameControllerGUI
///
/// @author	Sean Turner (ST)
///
/// @brief	GUI display to test GameController behaviour on device.
//////////////////////////////////////////////////////////////////////////

/************************ EXTERNAL NAMESPACES ***************************/

using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

/************************ REQUIRED COMPONENTS ***************************/

/************************** THE SCRIPT CLASS ****************************/

public class GameControllerGUI : MonoBehaviour 
{
	/****************************** CONSTANTS *******************************/

	/***************************** SUB-CLASSES ******************************/

	/***************************** GLOBAL DATA ******************************/
	
	private Color								g_background = new Color(0.5f,0.5f,0.5f,0.75f);
	private Color								g_darkGrey = new Color(0.2f,0.2f,0.2f,1f);

	/*************************** GLOBAL METHODS *****************************/
	
	/***************************** PUBLIC DATA ******************************/
	
	public bool									m_bDrawGUI = true;					//!< Use this to turn off the OnGUI drawing in this script
	
	/***************************** PRIVATE DATA *****************************/
	
	private Texture2D							m_whiteTexture = null;
	private GameController.GCInput				m_inputValueChanged = GameController.GCInput.None;
	private float								m_fInputValueChangedTimeout = 0.0f;
	private bool								m_bIsGamepadSnapshotValid = false;
	private bool								m_bIsExtendedSnapshotValid = false;
	private GameController.GCGamepadSnapShotDataV100 			m_gamepadSnapshot  = new GameController.GCGamepadSnapShotDataV100();
	private GameController.GCExtendedGamepadSnapShotDataV100 	m_extendedSnapshot = new GameController.GCExtendedGamepadSnapShotDataV100();

	/****************************** CALLBACKS *******************************/
	
	/**************************** CLASS METHODS *****************************/
	
	void Awake()
	{
		// Keep this class alive
		DontDestroyOnLoad(gameObject);
		DontDestroyOnLoad(this);
		
	    // Create a 2x2 white texture for drawing coloured rects
	    m_whiteTexture = new Texture2D(2, 2, TextureFormat.ARGB32, false);
	    m_whiteTexture.SetPixel(0, 0, Color.white);
	    m_whiteTexture.SetPixel(1, 0, Color.white);
	    m_whiteTexture.SetPixel(0, 1, Color.white);
	    m_whiteTexture.SetPixel(1, 1, Color.white);
	    m_whiteTexture.Apply();
		
		// Start GameController plugin and auto-assign player numbers to controllers that dont have them.
		GameController.Start();
		GameController.AutoAssignPlayerIndices();
		
		// Attach controller input value-change callback
		GameController.InputValueChangedEvent += InputValueChangedEvent;
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Draw GameControllerGUI status display.
	//////////////////////////////////////////////////////////////////////////
	void OnGUI()
	{
		if(m_bDrawGUI)
			DrawGameControllerGUI();
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Draw up to 4 controller statuses on screen using UnityGUI.
	/// 		Call this from your own OnGUI function to overlay on other UnityGUI.
	//////////////////////////////////////////////////////////////////////////
	public void DrawGameControllerGUI()
	{
		Color orgColor = GUI.color;
		TextAnchor orgAlign = GUI.skin.label.alignment;

#if UNITY_EDITOR
		int nNumControllers = 4;
#else
		int nNumControllers = GameController.GetNumControllers();
#endif

		float fControllerX = Screen.width * 0.05f;
		float fControllerY = Screen.width * 0.05f;
		float fControllerWidth = Screen.width * 0.4f;
		float fControllerHeight = fControllerWidth * 0.5f;

		if(nNumControllers >= 1)
		{
			DrawController(0, fControllerX, fControllerY, fControllerWidth, fControllerHeight);
		}
		
		if(nNumControllers >= 2)
		{
			fControllerX += fControllerWidth + 5.0f;
			DrawController(1, fControllerX, fControllerY, fControllerWidth, fControllerHeight);
		}
		
		if(nNumControllers >= 3)
		{
			fControllerX = Screen.width * 0.05f;
			fControllerY += fControllerHeight + 5.0f;
			DrawController(2, fControllerX, fControllerY, fControllerWidth, fControllerHeight);
		}
		
		if(nNumControllers >= 4)
		{
			fControllerX += fControllerWidth + 5.0f;
			DrawController(3, fControllerX, fControllerY, fControllerWidth, fControllerHeight);
		}
		
		if(Time.realtimeSinceStartup > m_fInputValueChangedTimeout)
			m_inputValueChanged = GameController.GCInput.None;
		
		GUI.color = orgColor;
		GUI.skin.label.alignment = orgAlign;
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Draw a controller.
	//////////////////////////////////////////////////////////////////////////
	void DrawController(int nControllerIndex, float fControllerX, float fControllerY, float fControllerWidth, float fControllerHeight)
	{
		if(GameController.SupportsExtendedGamepad(nControllerIndex))
		{
			// Grab a snapshot of the current state of the controller's ExtendedGamepad profile
			m_bIsExtendedSnapshotValid = GameController.GetExtendedGamepadSnapshot(nControllerIndex, ref m_extendedSnapshot);
			
			// Draw the ExtendedGamepad status
			DrawExtendedGamepad(nControllerIndex, fControllerX, fControllerY, fControllerWidth, fControllerHeight);
					
			m_bIsExtendedSnapshotValid = false;
		}
		else
		{
			// Grab a snapshot of the current state of the controller's Gamepad profile
			m_bIsGamepadSnapshotValid = GameController.GetGamepadSnapshot(nControllerIndex, ref m_gamepadSnapshot);
			
			// Draw the Gamepad status
			DrawGamepad(nControllerIndex, fControllerX, fControllerY, fControllerWidth, fControllerHeight);
					
			m_bIsGamepadSnapshotValid = false;
		}
	}
	
	//////////////////////////////////////////////////////////////////////////
	/// @brief	Draw a basic Gamepad controller
	//////////////////////////////////////////////////////////////////////////
	void DrawGamepad(int nControllerIndex, float fControllerX, float fControllerY, float fControllerWidth, float fControllerHeight)
	{
		GUI.BeginGroup(new Rect( fControllerX, fControllerY, fControllerWidth, fControllerHeight));
		
		// Controller background
		GUI.color = g_background;
		GUI.DrawTexture(new Rect( 0.0f, 0.0f, fControllerWidth, fControllerHeight), m_whiteTexture);
		GUI.color = m_bIsGamepadSnapshotValid ? Color.red : Color.white;
		GUI.skin.label.alignment = TextAnchor.MiddleCenter;
		GUI.Label( new Rect( 0.0f, 0.0f, fControllerWidth, fControllerHeight), nControllerIndex.ToString() );
		
		// Shoulder buttons
		float fShoulderWidth = fControllerWidth * 0.15f;
		float fShoulderHeight = fShoulderWidth * 0.3f;

		DrawButton(nControllerIndex, GameController.GCInput.gpLeftShoulder,  new Rect( 0.0f, 0.0f, fShoulderWidth, fShoulderHeight), "LS");
		DrawButton(nControllerIndex, GameController.GCInput.gpRightShoulder, new Rect( fControllerWidth-fShoulderWidth, 0.0f, fShoulderWidth, fShoulderHeight), "RS");
		
		// DPad
		float fDPadButtonSize = fControllerWidth * 0.05f;
		float fDPadLeft = 0.0f;
		float fDPadTop = fShoulderHeight * 3.0f;
		
		DrawButton(nControllerIndex, GameController.GCInput.gpDPadUp,    new Rect( fDPadLeft+fDPadButtonSize, fDPadTop, fDPadButtonSize, fDPadButtonSize), "U");
		DrawButton(nControllerIndex, GameController.GCInput.gpDPadDown,  new Rect( fDPadLeft+fDPadButtonSize, fDPadTop+fDPadButtonSize+fDPadButtonSize, fDPadButtonSize, fDPadButtonSize), "D");
		DrawButton(nControllerIndex, GameController.GCInput.gpDPadLeft,  new Rect( fDPadLeft, fDPadTop+fDPadButtonSize, fDPadButtonSize, fDPadButtonSize), "L");
		DrawButton(nControllerIndex, GameController.GCInput.gpDPadRight, new Rect( fDPadLeft+fDPadButtonSize+fDPadButtonSize, fDPadTop+fDPadButtonSize, fDPadButtonSize, fDPadButtonSize), "R");

		// ABXY Buttons
		float fABXYButtonSize = fControllerWidth * 0.05f;
		float fABXYLeft = fControllerWidth-(fABXYButtonSize*3.0f);
		float fABXYTop = fShoulderHeight * 3.0f;
		
		DrawButton(nControllerIndex, GameController.GCInput.gpButtonY, new Rect( fABXYLeft+fABXYButtonSize, fABXYTop, fABXYButtonSize, fABXYButtonSize), "Y");
		DrawButton(nControllerIndex, GameController.GCInput.gpButtonA, new Rect( fABXYLeft+fABXYButtonSize, fABXYTop+fABXYButtonSize+fABXYButtonSize, fABXYButtonSize, fABXYButtonSize), "A");
		DrawButton(nControllerIndex, GameController.GCInput.gpButtonX, new Rect( fABXYLeft, fABXYTop+fABXYButtonSize, fABXYButtonSize, fABXYButtonSize), "X");
		DrawButton(nControllerIndex, GameController.GCInput.gpButtonB, new Rect( fABXYLeft+fABXYButtonSize+fABXYButtonSize, fABXYTop+fABXYButtonSize, fABXYButtonSize, fABXYButtonSize), "B");

		GUI.EndGroup();
	}

	//////////////////////////////////////////////////////////////////////////
	/// @brief	Draw an ExtendedGamepad controller.
	//////////////////////////////////////////////////////////////////////////
	void DrawExtendedGamepad(int nControllerIndex, float fControllerX, float fControllerY, float fControllerWidth, float fControllerHeight)
	{
		// Draw the basic Gamepad controller and then add in the extended inputs.
		DrawGamepad(nControllerIndex, fControllerX, fControllerY, fControllerWidth, fControllerHeight);
		
		GUI.BeginGroup(new Rect( fControllerX, fControllerY, fControllerWidth, fControllerHeight));
		
		// Trigger buttons
		float fShoulderWidth = fControllerWidth * 0.15f;
		float fShoulderHeight = fShoulderWidth * 0.3f;

		DrawButton(nControllerIndex, GameController.GCInput.exLeftTrigger, new Rect( fShoulderWidth, 0.0f, fShoulderWidth, fShoulderHeight), "LT");
		DrawButton(nControllerIndex, GameController.GCInput.exRightTrigger, new Rect( fControllerWidth-fShoulderWidth-fShoulderWidth, 0.0f, fShoulderWidth, fShoulderHeight), "RT");
		
		// Left Thumbstick
		float fThumbButtonSize = fControllerWidth * 0.05f;
		float fThumbLeft = 0.0f;
		float fThumbTop = fControllerHeight-(fThumbButtonSize*3.0f);
		
		DrawButton(nControllerIndex, GameController.GCInput.exLeftThumbstickUp,    new Rect( fThumbLeft+fThumbButtonSize, fThumbTop, fThumbButtonSize, fThumbButtonSize), "^");
		DrawButton(nControllerIndex, GameController.GCInput.exLeftThumbstickDown,  new Rect( fThumbLeft+fThumbButtonSize, fThumbTop+fThumbButtonSize+fThumbButtonSize, fThumbButtonSize, fThumbButtonSize), "v");
		DrawButton(nControllerIndex, GameController.GCInput.exLeftThumbstickLeft,  new Rect( fThumbLeft, fThumbTop+fThumbButtonSize, fThumbButtonSize, fThumbButtonSize), "<");
		DrawButton(nControllerIndex, GameController.GCInput.exLeftThumbstickRight, new Rect( fThumbLeft+fThumbButtonSize+fThumbButtonSize, fThumbTop+fThumbButtonSize, fThumbButtonSize, fThumbButtonSize), ">");

		// Right Thumbstick
		fThumbLeft = fControllerWidth-(fThumbButtonSize*3.0f);
		
		DrawButton(nControllerIndex, GameController.GCInput.exRightThumbstickUp,    new Rect( fThumbLeft+fThumbButtonSize, fThumbTop, fThumbButtonSize, fThumbButtonSize), "^");
		DrawButton(nControllerIndex, GameController.GCInput.exRightThumbstickDown,  new Rect( fThumbLeft+fThumbButtonSize, fThumbTop+fThumbButtonSize+fThumbButtonSize, fThumbButtonSize, fThumbButtonSize), "v");
		DrawButton(nControllerIndex, GameController.GCInput.exRightThumbstickLeft,  new Rect( fThumbLeft, fThumbTop+fThumbButtonSize, fThumbButtonSize, fThumbButtonSize), "<");
		DrawButton(nControllerIndex, GameController.GCInput.exRightThumbstickRight, new Rect( fThumbLeft+fThumbButtonSize+fThumbButtonSize, fThumbTop+fThumbButtonSize, fThumbButtonSize, fThumbButtonSize), ">");

		GUI.EndGroup();
	}
	
	/// @brief	Input value-change callback.
	void InputValueChangedEvent(int nController, GameController.GCInput input)
	{
		m_inputValueChanged = input;
		m_fInputValueChangedTimeout = Time.realtimeSinceStartup + 0.5f;
	}
	
	/// @brief	Colour inputs blue if they have just received a value-change callback.
	/// 		Red if they are classed as Pressed. Dark grey otherwise.
	Color GCInputColor(int nControllerIndex, GameController.GCInput input)
	{
		if(m_inputValueChanged == input)
			return Color.blue;
		
		if(GameController.GetInputPressed(nControllerIndex, input))
			return Color.red;
			
		return g_darkGrey;
	}
	
	/// @brief	Draw a coloured rectangle with a label to represent a button.
	void DrawButton(int nControllerIndex, GameController.GCInput input, Rect rect, String sLabel)
	{
		float fSnapshotValue = 0.0f;
		
		// Get input's value from the current snapshot
		if(m_bIsExtendedSnapshotValid)
			fSnapshotValue = m_extendedSnapshot.GetInputValue(input);
		else
		if(m_bIsGamepadSnapshotValid)
			fSnapshotValue = m_gamepadSnapshot.GetInputValue(input);
		
		GUI.color = GCInputColor(nControllerIndex, input);					// Colour button background to indicate value-changed event or pressed status.
		GUI.DrawTexture( rect, m_whiteTexture);
		GUI.color = (fSnapshotValue == 0.0f) ? Color.white : Color.black;	// Colour label black or white to indicate snapshot value.
		GUI.skin.label.alignment = TextAnchor.MiddleCenter;
		GUI.Label( rect, sLabel );
	}
}

		

