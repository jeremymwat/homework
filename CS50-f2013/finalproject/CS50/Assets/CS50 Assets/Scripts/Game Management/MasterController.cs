using UnityEngine;
using System.Collections;

public class MasterController : MonoBehaviour {

	public GameObject sphere;
	private BallGame ballGame;

	public float timer;

	public bool timerRunning;

	public int points;

	// game over splash texture
	public Texture gameOver;

	// next level splash texture
	public Texture nextLevelIcon;

	[HideInInspector]
	public int p1Lives;
	[HideInInspector]
	public int p2Lives;

	public int level = 1;

	// Use this for initialization
	void Start () {
		ballGame = sphere.GetComponent<BallGame>();
		p1Lives = 4;
		p2Lives = 3;
		timer = 400;
		timerRunning = true;
	}
	
	// Update is called once per frame
	void Update () {

		// if current AI is defeated, go to next level
		if (p2Lives == 0)
		{
			sphere.rigidbody.velocity = new Vector3 (0, 0, 0);
			timerRunning = false;
			if (Input.GetKeyDown("space"))
			{
				NextLevel();

			}
		}

		if (p1Lives == 0)
		{
			timerRunning = false;
		}


		if (timerRunning == true)
			timer -= Time.deltaTime * 5;
			
	}

	void OnGUI() {
		if (p1Lives == 0)
		{
			GUI.DrawTexture (new Rect ((Screen.width - 300) / 2, (Screen.height - 300) / 2, 300, 300), gameOver);
			Time.timeScale = 0f;


			// reset game
			if (Input.GetKeyDown("space"))
				GameOverReset();			
		}

		// display next level text
		if (p2Lives == 0)
			GUI.DrawTexture (new Rect ((Screen.width - 300) / 2, (Screen.height - 300) / 2, 300, 300), nextLevelIcon);
		
	}

	void GameOverReset ()
	{
		p1Lives = 4;
		p2Lives = 3;
		level = 1;
		ballGame.resetGame();
		Time.timeScale = 1f;
		ballGame.minZVel = 7f;
		points = 0;
		timerRunning = true;

	}

	// reset p2 lives
	void NextLevel()
	{
		level++;
		p2Lives = 3;
		ballGame.minZVel++;
		points += (int)timer;
		timer = 400 + 100 * level;
		timerRunning = true;

	}

}


//TODO - Finish scoring system
//TODO - create powerups
//TODO - add soundtrack