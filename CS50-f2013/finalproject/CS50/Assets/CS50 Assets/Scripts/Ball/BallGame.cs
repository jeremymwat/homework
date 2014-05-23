using UnityEngine;
using System.Collections;

public class BallGame : MonoBehaviour {

	[HideInInspector]
	public int numPaddleCollisions;

	// to use vars and methods from master game controller
	public GameObject masterGameController;
	private MasterController masterController;

	// minimum Z velocity during game
	[HideInInspector]
	public float minZVel; 

	// amount of velocity to add to ball every paddle hit
	private int addSpeed = 20;

	public AudioClip impact;

	// starting position for ball
	private Vector3 startingPos = new Vector3( 0, 1, -3);

	// Use this for initialization
	void Start () {
		minZVel = 7f;
		rigidbody.velocity = new Vector3(0,0,minZVel);
		masterController = masterGameController.GetComponent<MasterController>();
	}
	
	// Update is called once per frame
	void FixedUpdate () {
		// put some english on it
		rigidbody.AddForce(rigidbody.angularVelocity.x / 2, rigidbody.angularVelocity.y / 2, 0);


		// unity's physics engine can be wonky, this ensures the ball doesn't accidentally go to slowly due to weird collisions
		if (Mathf.Abs(rigidbody.velocity.z) < Mathf.Abs (minZVel) && masterController.timerRunning == true)
		{
			rigidbody.AddForce(0,0, (Mathf.Sign(rigidbody.velocity.z) * 20));
			Debug.Log ("adding force");
		}
		
	}



	void OnCollisionEnter(Collision col)
	{
		if (col.gameObject.name == "p1Paddle" || col.gameObject.name == "AIpaddle") {
		
			numPaddleCollisions++;
			rigidbody.AddForce(0,0, (Mathf.Sign(rigidbody.velocity.z) * (addSpeed * masterController.level)));

			if (col.gameObject.name == "p1Paddle")
				masterController.points += 5 * masterController.level;
		
		}

		if (col.gameObject.name == "P1Back") {
			resetGame();
			masterController.p1Lives--;
		}

		if (col.gameObject.name == "P2Back") { 
			resetGame();
			masterController.p2Lives--;
		}

		audio.PlayOneShot(impact, 1f);

	
	}

	public void resetGame() {
		this.rigidbody.position = startingPos;
		rigidbody.velocity = new Vector3(0,0,(minZVel + masterController.level));
		rigidbody.angularVelocity = new Vector3(0,0,0);
				


	}
}