using UnityEngine;
using System.Collections;

public class paddleAI : MonoBehaviour {

	public GameObject sphere;
	
	private BallInfo ballInfo;	

	private float speed = 2f;

	// to use vars and methods from master game controller
	public GameObject masterGameController;
	private MasterController masterController;



	// Use this for initialization
	void Start () {
		ballInfo = sphere.GetComponent<BallInfo>();
		masterController = masterGameController.GetComponent<MasterController>();
	}
	
	// Update is called once per frame
	void FixedUpdate () {

		// move AI paddle to ball
		Vector3 direction = ((ballInfo.ballPos - new Vector3(0,0, ballInfo.ballPos.z)) - (rigidbody.position - new Vector3(0,0, rigidbody.position.z))).normalized;
		rigidbody.MovePosition(rigidbody.position + (speed * (float)masterController.level / 2f) * direction * Time.deltaTime);
	}
}
