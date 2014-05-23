using UnityEngine;
using System.Collections;

//TODO deal with host disconnect


public class NetworkManager : MonoBehaviour {

	private const string typeName = "MultiPongCS50";
	private const string gameName = "GameRoom";

	public GameObject leapController;


	

	public Camera hostCamera;
	public Camera clientCamera;

	private HostData[] hostList;

	void Start()
	{
		Time.timeScale = 0f;
	}



	private void RefreshHostList()
	{
		MasterServer.RequestHostList(typeName);
	}

	void OnMasterServerEvent(MasterServerEvent msEvent)
	{
		if (msEvent == MasterServerEvent.HostListReceived)
			hostList = MasterServer.PollHostList();
	}	

	private void JoinServer(HostData hostData)
	{
		Network.Connect(hostData);
	}

	void OnConnectedToServer()
	{
		Debug.Log ("Server Joined");
		SpawnPlayer(.5f, -1.5f, 5f, Quaternion.Euler(0, 180, 0));
		clientCamera.enabled = true;
		hostCamera.enabled = false;
	}

	void SpawnPlayer(float x, float y, float z, Quaternion q)
	{
		Network.Instantiate(leapController, new Vector3(x, y, z), q, 0);
	}


	private void StartServer() 
	{
		Network.InitializeServer(4, 25000, !Network.HavePublicAddress());
		MasterServer.RegisterHost(typeName, gameName);
		hostCamera.enabled = true;
		clientCamera.enabled = false;
	}

	void OnServerInitialized() 
	{
		Debug.Log("server initialized");
		SpawnPlayer(.5f, 1.5f, -10f, Quaternion.identity);
	}

	void OnGUI()
	{
		if (!Network.isClient && !Network.isServer)
		{

			Npause();	

			if (GUI.Button (new Rect(50, 50, 100, 40), "Start Server"))
				StartServer();

			if (GUI.Button(new Rect(50, 100, 100, 40), "Find Games"))
				RefreshHostList();

			if (hostList != null)
			{
				for (int i = 0; i < hostList.Length; i++)
					if (GUI.Button(new Rect(400, 100 + (110 * i), 300, 100), hostList[i].gameName))
						JoinServer (hostList[i]);
			}
		}
	}

	// Update is called once per frame
	void Update () {
		if (Input.GetKey(KeyCode.W))
		{
			Nunpause();
			
			if (networkView.isMine)
				networkView.RPC ("Nunpause", RPCMode.OthersBuffered);
		}

		if (Input.GetKey(KeyCode.E))
		{
			Npause();

			if (networkView.isMine)
				networkView.RPC ("Npause", RPCMode.OthersBuffered);
		}

		if (Input.GetKey(KeyCode.Escape))
		{
			Network.Disconnect();

		}

	}

	void OnPlayerDisconnected()
	{

		Network.Disconnect();
	}

[RPC] public void Npause()
	{
		Time.timeScale = 0f;
	}


[RPC]public void Nunpause()
	{
		Time.timeScale = 1f;
	}

}
