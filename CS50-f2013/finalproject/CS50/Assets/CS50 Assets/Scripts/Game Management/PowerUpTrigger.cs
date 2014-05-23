using UnityEngine;
using System.Collections;

public class PowerUpTrigger : MonoBehaviour {

	// Use this for initialization
	void OnTriggerEnter () {
		Debug.Log ("HIT!");
	
	
	
	}

	void Update() {
		transform.Rotate(0, 60 * Time.deltaTime, 0);

	}
}
