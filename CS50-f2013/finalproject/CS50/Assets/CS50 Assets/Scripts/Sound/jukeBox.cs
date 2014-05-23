using UnityEngine;
using System.Collections;

public class jukeBox : MonoBehaviour {

	public AudioClip[] soundTrack;
	private AudioClip songPlaying;

	private int songNum;

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {

		if (!audio.isPlaying)
		{
			songNum = (int)Random.Range(0,soundTrack.Length - 1);
			Debug.Log("Song number " + songNum);
			audio.clip = soundTrack[songNum];
			audio.Play();
			
		}
	}
}
