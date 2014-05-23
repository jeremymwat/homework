using UnityEngine;
using System.Collections;

public class leapPaddle : MonoBehaviour {
	
	public GameObject leapController;
	private LeapBehavior leapBehavior;


	
	Vector3 paddlePosition;
	
	Rigidbody rb;
	
	float posX;
	float posY;
	float posZ;

	private int reverseXAxis;
	
	float posDivider = 50;
	
	// Use this for initialization
	void Start () {
		leapBehavior = leapController.GetComponent<LeapBehavior>();	
		rb = GetComponent<Rigidbody>();	
		//paddlePosition = Vector3(leapBehavior.handX, leapBehavior.handY, leapBehavior.handZ);
		if (Network.isClient)
			reverseXAxis = -1;
		else
			reverseXAxis = 1;
	}


	// Update is called once per frame
	void FixedUpdate () {

		if (networkView != null)
		{
			if (networkView.isMine)
			{
				if (leapBehavior != null)
				{
					movePaddle();
					
				}
			}
		} else 
		{
			if (leapBehavior != null)
			{
				movePaddle();
				
			}
		}





	}

	void movePaddle()
	{
		posX = reverseXAxis * (leapBehavior.handX / (posDivider / 2));
		posY =  (leapBehavior.handY / posDivider) - 3;
		posZ = leapController.transform.position.z;//(leapBehavior.handZ / posDivider);
		paddlePosition = new Vector3(posX, posY, posZ);//(leapBehavior.handX, leapBehavior.handY, leapBehavior.handZ);
		rb.MovePosition(paddlePosition);

	}
}
