using UnityEngine;
using System.Collections;

public class GUIpong : MonoBehaviour {

	// get info from ball
	public GameObject sphere;
	private BallInfo ballInfo;
	private BallGame ballGame;

	// icon for lives indicator
	public Texture p1livesIcon;
	public Texture p2livesIcon;

	// talk to master gamea controller
	public GameObject masterGameController;
	private MasterController masterController;

	public GUIStyle levelDisplay;

	public GUIStyle livesDisplay;

	// Use this for initialization
	void Start () {

		ballGame = sphere.GetComponent<BallGame>();	
		masterController = masterGameController.GetComponent<MasterController>();

	}
	
	void OnGUI() {

		// debug console info
		//GUI.Box (new Rect (10,40,120,110), ballInfo.ballVelocity + "\n" + ballGame.numPaddleCollisions + "\n P1 Lives: " + masterController.p1Lives + "\n AI lives: " + masterController.p2Lives + "\n minZVel: " + ballGame.minZVel + "\nTimer: " + (int)masterController.timer);

		// display player 1 lives
		GUI.Label (new Rect(10, 8, 80, 20), "Player 1: ", livesDisplay);
		for (int i = 0; i < masterController.p1Lives; i++) 
			GUI.DrawTexture (new Rect (70 + (i * 20), 8, 16, 16), p1livesIcon);
	
		// display player 2 lives
		GUI.Label (new Rect(Screen.width - 120, 8, 80, 20), "Player 2: ", livesDisplay);	
		for (int i = 0; i < masterController.p2Lives; i++) 
			GUI.DrawTexture (new Rect (Screen.width - 60 + (i * 20), 8, 16, 16), p2livesIcon);

		//show current level
		GUI.Label (new Rect((Screen.width - 50) / 2, 5, 100, 25), "Level " + masterController.level, levelDisplay);

		//show current points
		GUI.Label (new Rect((Screen.width - 50) / 2, Screen.height - 25, 100, 25), "Points: " + masterController.points, levelDisplay);

		//show bonus timer
		GUI.Label (new Rect(60, Screen.height - 25, 100, 25), "Bonus Points: " + (int)masterController.timer, levelDisplay);

	}	

	void Update() {

	
	}
	
}
