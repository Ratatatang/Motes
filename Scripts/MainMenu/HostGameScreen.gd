extends Node2D

@export var address = "127.0.0.1"
@export var port = 8910

enum gamemodes {
	FFA,
	TEAMS
}

var gamemodesList = [gamemodes.FFA, gamemodes.TEAMS]
var gamemode = 0

func _ready():
	multiplayer.peer_connected.connect(playerConnect)
	multiplayer.peer_disconnected.connect(playerDisconnect)
	multiplayer.connected_to_server.connect(connectToServer)
	multiplayer.connection_failed.connect(connectionFailed)

func playerConnect(id):
	print("Player Connected: "+ str(id))

func playerDisconnect(id):
	print("Player Disconnected "+ str(id))

func connectToServer():
	print("Connected to server!")
	%Start.disabled = true
	sendPlayerInfo.rpc_id(1, multiplayer.get_unique_id(), %Name.text)

func connectionFailed():
	print("Failed to connect to server!")

@rpc("any_peer")
func sendPlayerInfo(id, playerID):
	if !MasterInfo.playerIDs.has(id):
		MasterInfo.playerIDs.merge({id: playerID})
	
	if multiplayer.is_server():
		for i in MasterInfo.playerIDs.keys():
			sendPlayerInfo.rpc(i, MasterInfo.playerIDs.get(i))

@rpc("any_peer", "call_local")
func startGame():
	var master = load("res://Scenes/Master.tscn")
	get_tree().change_scene_to_packed(master)

func checkGamemode():
	if(gamemode < 0):
		gamemode = gamemodesList.size()-1
	if(gamemode > gamemodesList.size()-1):
		gamemode = 0
	
	match gamemodesList[gamemode]:
		#gamemode.FFA
		0:
			%Gamemode.text = "[center]Free-For-All[/center]"
			
		#gamemode.TEAMs
		1:
			%Gamemode.text = "[center]Teams[/center]"

func _on_host_pressed():
	if %Name.text != "":
		MasterInfo.singleplayer = false
		MasterInfo.peer = ENetMultiplayerPeer.new()
		var error = MasterInfo.peer.create_server(port, 2)
		
		if error != OK:
			print("Cannot Host! Error: "+error)
			return
		
		multiplayer.set_multiplayer_peer(MasterInfo.peer)
		sendPlayerInfo(multiplayer.get_unique_id(), %Name.text)
		%Join.disabled = true
		print("Waiting for players...")

func _on_join_pressed():
	if %Name.text != "":
		MasterInfo.singleplayer = false
		MasterInfo.peer = ENetMultiplayerPeer.new()
		MasterInfo.peer.create_client(address, port)
		
		multiplayer.set_multiplayer_peer(MasterInfo.peer)

func _on_start_pressed():
	if MasterInfo.singleplayer:
		MasterInfo.playerIDs.merge({1: "player"})
	
	await RenderingServer.frame_post_draw
	startGame.rpc()

func _on_scroll_gamemode_left():
	gamemode += 1
	checkGamemode()

func _on_scroll_gamemode_right():
	gamemode -= 1
	checkGamemode()
