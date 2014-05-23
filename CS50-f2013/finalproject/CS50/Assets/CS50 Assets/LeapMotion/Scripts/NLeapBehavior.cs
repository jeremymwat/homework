using UnityEngine;
using System.Collections;
using Leap;

public class NLeapBehavior : MonoBehaviour {

	Controller controller;
	HandList hands;
	Vector position;
	Hand rightmost; 
	public float handX;
	public float handY;
	public float handZ;
	
	
	Frame frame;
	
	void Start ()
	{
		controller = new Controller();
		
	}
	
	void Update ()
	{
		if (controller.Frame () != null)
		{
			frame = controller.Frame();
			hands = frame.Hands;
			rightmost = hands.Rightmost;
			handX = rightmost.PalmPosition.x;
			handY = rightmost.PalmPosition.y;
			handZ = rightmost.PalmPosition.z;
		}
		
		if (controller == null)
			controller = new Controller();
	}
}