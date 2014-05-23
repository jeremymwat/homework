using UnityEngine;
using System.Collections;

public class NleapPaddle : MonoBehaviour {
	
	public GameObject leapController;
	private LeapBehavior leapBehavior;
	
	
	
	Vector3 paddlePosition;
	
	Rigidbody rb;
	
	float posX;
	float posY;
	float posZ;
	
	float posDivider = 50;
	
	// Use this for initialization
	void Start () {
		leapBehavior = leapController.GetComponent<LeapBehavior>();	
		rb = GetComponent<Rigidbody>();	
		//paddlePosition = Vector3(leapBehavior.handX, leapBehavior.handY, leapBehavior.handZ);
	}
	
	// Update is called once per frame
	void FixedUpdate () {
		if (networkView.isMine)
		{
			if (leapBehavior != null)
			{
				posX = -(leapBehavior.handX / (posDivider / 2));
				posY =  (leapBehavior.handY / posDivider) - 3;
				posZ = 8f;//(leapBehavior.handZ / posDivider);
				paddlePosition = new Vector3(posX, posY, posZ);//(leapBehavior.handX, leapBehavior.handY, leapBehavior.handZ);
				rb.MovePosition(paddlePosition);
				
			}
		}
	}
}
