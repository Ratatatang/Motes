extends Node2D

@export var address = "127.0.0.1"

var playerListing = load("res://Scenes/MainMenu/PlayerListing.tscn")

var gamemodesList = ["FreeForAll", "Teams"]
@export var gamemode = 0

func _ready():
	multiplayer.peer_connected.connect(playerConnect)
	multiplayer.peer_disconnected.connect(playerDisconnect)
	multiplayer.connected_to_server.connect(connectToServer)
	multiplayer.connection_failed.connect(connectionFailed)
	
	if "--server" in OS.get_cmdline_args():
		hostDedicated()

func playerConnect(id):
	print("Player Connected: "+ str(id))

func playerDisconnect(id):
	print("Player Disconnected "+ str(id))

func connectToServer():
	print("Connected to server!")
	%Start.disabled = true
	%Join.disabled = true
	$Buttons/ScrollGamemodeLeft.visible = false
	$Buttons/ScrollGamemodeRight.visible = false
	sendPlayerInfo.rpc_id(1, multiplayer.get_unique_id(), %Name.text)

func connectionFailed():
	print("Failed to connect to server!")

@rpc("any_peer")
func sendPlayerInfo(id, playerID):
	if !MasterInfo.playerIDs.has(id):
		MasterInfo.playerIDs.merge({id: playerID})
		
		var newPlayer = playerListing.instantiate()
		newPlayer.setPlayerName(playerID)
		newPlayer.id = id
		
		if id == 1:
			newPlayer.togglePlayerHost(true)
		
		match gamemodesList[gamemode]:
			"FreeForAll":
				newPlayer.toggleTeams(false)
			"Teams":
				newPlayer.toggleTeams(true)
		
		%PlayersList.add_child(newPlayer)

	if multiplayer.is_server():
		for i in MasterInfo.playerIDs.keys():
			sendPlayerInfo.rpc(i, MasterInfo.playerIDs.get(i))

@rpc("any_peer", "call_local")
func startGame():
	var master = load("res://Scenes/Master.tscn")
	get_tree().change_scene_to_packed(master)

@rpc("any_peer", "call_local")
func checkGamemode():
	if(gamemode < 0):
		gamemode = gamemodesList.size()-1
	if(gamemode > gamemodesList.size()-1):
		gamemode = 0
		
	match gamemodesList[gamemode]:
		"FreeForAll":
			%Gamemode.text = "[center]Free-For-All[/center]"
			
			for player in %PlayersList.get_children():
				player.toggleTeams(false)
		
		"Teams":
			%Gamemode.text = "[center]Teams[/center]"
			
			for player in %PlayersList.get_children():
				player.toggleTeams(true)

func _on_host_pressed():
	if %Name.text != "":
		MasterInfo.singleplayer = false
		MasterInfo.peer = ENetMultiplayerPeer.new()
		var error = MasterInfo.peer.create_server(int(%Port.text), 2)
		
		if error != OK:
			print("Cannot Host! Error: "+error)
			return
		
		multiplayer.set_multiplayer_peer(MasterInfo.peer)
		sendPlayerInfo(multiplayer.get_unique_id(), %Name.text)
		%Join.disabled = true
		print("Waiting for players...")

func hostDedicated():
	MasterInfo.singleplayer = false
	MasterInfo.peer = ENetMultiplayerPeer.new()
	var error = MasterInfo.peer.create_server(8910, 2)
		
	if error != OK:
		print("Cannot Host! Error: "+error)
		return
		
	multiplayer.set_multiplayer_peer(MasterInfo.peer)
	print("Waiting for players...")

func _on_join_pressed():
	if %Name.text != "":
		MasterInfo.singleplayer = false
		MasterInfo.peer = ENetMultiplayerPeer.new()
		MasterInfo.peer.create_client(address, int(%Port.text))
		
		multiplayer.set_multiplayer_peer(MasterInfo.peer)

func _on_start_pressed():
	if MasterInfo.singleplayer:
		MasterInfo.playerIDs.merge({1: "player"})
	
	var playerInfo = {}
	
	for player in %PlayersList.get_children():
		playerInfo.merge({player.id: player.packageInfo()})
	
	MasterInfo.gameInfo = [gamemodesList[gamemode], playerInfo]
	
	await RenderingServer.frame_post_draw
	startGame.rpc()

@rpc("any_peer")
func _on_scroll_gamemode_left():
	gamemode += 1
	checkGamemode()
	
	if multiplayer.get_unique_id() == 1:
		_on_scroll_gamemode_left.rpc()

@rpc("any_peer")
func _on_scroll_gamemode_right():
	gamemode -= 1
	checkGamemode()
	
	if multiplayer.get_unique_id() == 1:
		_on_scroll_gamemode_right.rpc()

func _on_add_ai_player_pressed():
	var newPlayer = playerListing.instantiate()
	newPlayer.AIPlayer = true
	
	var AIPlayers = 0
	for player in %PlayersList.get_children():
		if(player.AIPlayer):
			AIPlayers += 1
	
	if AIPlayers == 0:
		newPlayer.setPlayerName("AI Player")
	else:
		newPlayer.setPlayerName("AI Player " + str(AIPlayers))
		
	match gamemodesList[gamemode]:
		"FreeForAll":
			newPlayer.toggleTeams(false)
		"Teams":
			newPlayer.toggleTeams(true)
		
	%PlayersList.add_child(newPlayer)
