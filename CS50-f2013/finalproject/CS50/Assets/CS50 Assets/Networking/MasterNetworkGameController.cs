using UnityEngine;
using System.Collections;

public class MasterNetworkGameController : MonoBehaviour {
	
	public GameObject sphere;
	private nBallGame ballGame;
		
	// game over splash texture
	public Texture gameOver;

	public GameObject networkController;
	private NetworkManager networkManager;

	[HideInInspector]
	public int p1Lives;
	[HideInInspector]
	public int p2Lives;
	

	// Use this for initialization
	void Start () {
		networkManager = networkController.GetComponent<NetworkManager>();
		ballGame = sphere.GetComponent<nBallGame>();
		p1Lives = 5;
		p2Lives = 5;

	}
	
	// Update is called once per frame
	void Update () 
	{
					
	}


[RPC] void OnGUI() 
	{
		if (p1Lives == 0 || p2Lives == 0)
		{
			GUI.DrawTexture (new Rect ((Screen.width - 300) / 2, (Screen.height - 300) / 2, 300, 300), gameOver);
			networkManager.Npause();
					
			// reset game
			if (Input.GetKeyDown("space"))
			{
				if (Network.isServer)
				{
					GameOverReset();		
					if (networkView.isMine)
						networkView.RPC ("GameOverReset", RPCMode.OthersBuffered);
				}
			}
		}

	}


[RPC] void GameOverReset ()
	{
		p1Lives = 4;
		p2Lives = 4;
		ballGame.resetGame();
		networkManager.Nunpause();
		ballGame.minZVel = 7f;
	}
}


//TODO - Finish scoring system
//TODO - create powerups
//TODO - add soundtrack