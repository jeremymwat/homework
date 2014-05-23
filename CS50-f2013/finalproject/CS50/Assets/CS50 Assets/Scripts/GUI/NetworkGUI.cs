using UnityEngine;
using System.Collections;

public class NetworkGUI : MonoBehaviour {
	
	// get info from ball
	public GameObject sphere;
	private BallInfo ballInfo;
	private nBallGame ballGame;
	
	// icon for lives indicator
	public Texture livesIcon;
	
	// talk to master gamea controller
	public GameObject masterGameController;
	private MasterNetworkGameController masterController;
	
	public GUIStyle levelDisplay;
	
	public GUIStyle livesDisplay;
	
	// Use this for initialization
	void Start () {
		//ballInfo = sphere.GetComponent<BallInfo>();	
		//ballGame = sphere.GetComponent<nBallGame>();	
		masterController = masterGameController.GetComponent<MasterNetworkGameController>();
		
	}


[RPC]	void OnGUI() {
		
		// debug console info
		//GUI.Box (new Rect (10,40,120,110), ballInfo.ballVelocity + "\n" + ballGame.numPaddleCollisions + "\n P1 Lives: " + masterController.p1Lives + "\n AI lives: " + masterController.p2Lives + "\n minZVel: " + ballGame.minZVel);

		if (Network.isClient || Network.isServer)
		{
			// display player 1 lives
			GUI.Label (new Rect(10, 8, 80, 20), "Player 1: ", livesDisplay);
			for (int i = 0; i < masterController.p1Lives; i++) 
				GUI.DrawTexture (new Rect (70 + (i * 20), 8, 16, 16), livesIcon);
			
			// display player 2 lives
			GUI.Label (new Rect(Screen.width - 160, 8, 80, 20), "Player 2: ", livesDisplay);	
			for (int i = 0; i < masterController.p2Lives; i++) 
				GUI.DrawTexture (new Rect (Screen.width - 100 + (i * 20), 8, 16, 16), livesIcon);
		}

	}	
	
	void Update() {
		
		
	}
	
}
