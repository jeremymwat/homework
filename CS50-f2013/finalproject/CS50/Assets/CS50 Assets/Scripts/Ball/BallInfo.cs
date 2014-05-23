using UnityEngine;
using System.Collections;

public class BallInfo : MonoBehaviour {
	
	[HideInInspector]
	public string ballVelocity;
	[HideInInspector]
	public Vector3 ballPos;
	
	Rigidbody rb;
	
	// Use this for initialization
	void Start () {
		rb = GetComponent<Rigidbody>();
	}
	
	// Update is called once per frame
	void Update () {
		ballPos = rigidbody.position;
		ballVelocity = rb.velocity.ToString();
	}
	
	
}
