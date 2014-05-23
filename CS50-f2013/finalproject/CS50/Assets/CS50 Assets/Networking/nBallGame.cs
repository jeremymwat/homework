using UnityEngine;
using System.Collections;

public class nBallGame : MonoBehaviour {
	
	[HideInInspector]
	public int numPaddleCollisions;
	
	// to use vars and methods from master game controller
	public GameObject masterGameController;
	private MasterNetworkGameController masterController;
	
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
		rigidbody.velocity = new Vector3(0,0,-minZVel);
		masterController = masterGameController.GetComponent<MasterNetworkGameController>();
	}
	
	// Update is called once per frame
	void FixedUpdate () {
		// put some english on it
		rigidbody.AddForce(rigidbody.angularVelocity.x / 2, rigidbody.angularVelocity.y / 2, 0);
		
		
		// unity's physics engine can be wonky, this ensures the ball doesn't accidentally go to slowly due to weird collisions
		if (Mathf.Abs(rigidbody.velocity.z) < Mathf.Abs (minZVel) && Time.time != 0f)
		{
			rigidbody.AddForce(0,0, (Mathf.Sign(rigidbody.velocity.z) * 20));
			Debug.Log ("adding force");
		}
		
	}
	
	

	[RPC] void OnCollisionEnter(Collision col)
	{
		if (col.gameObject.name == "p1Paddle" || col.gameObject.name == "AIpaddle") {
			
			numPaddleCollisions++;
			rigidbody.AddForce(0,0, (Mathf.Sign(rigidbody.velocity.z) * addSpeed));
			

		}
		
		if (col.gameObject.name == "P1Back") {
			if (Network.isServer)
				p1LoseLife();
		}
		
		if (col.gameObject.name == "P2Back") { 
			if (Network.isServer)
				p2LoseLife();
		}
		
		audio.PlayOneShot(impact, 1f);
		
		
	}
	
	[RPC] public void resetGame() {
		this.rigidbody.position = startingPos;
		rigidbody.velocity = new Vector3(0,0,-minZVel);
		rigidbody.angularVelocity = new Vector3(0,0,0);
	}


	[RPC]	void p1LoseLife()
	{

		if (networkView.isMine)
			networkView.RPC ("resetGame", RPCMode.OthersBuffered);
		masterController.p1Lives--;
		resetGame();

		if (networkView.isMine)
			networkView.RPC ("p1LoseLife", RPCMode.OthersBuffered);
	}


	[RPC]	void p2LoseLife()
	{
		if (networkView.isMine)
			networkView.RPC ("resetGame", RPCMode.OthersBuffered);
		masterController.p2Lives--;
		resetGame();

		if (networkView.isMine)
			networkView.RPC ("p2LoseLife", RPCMode.OthersBuffered);
		
	}

}