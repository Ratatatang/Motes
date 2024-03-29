extends Node2D

enum actions {
	NONE,
	SELECTING,
	MOVING,
	CARD,
	INSPECTING,
	STATUS
}

enum gamemodes {
	FFA,
	TEAMS
}

var currentAction = actions.NONE

var playerScene = "res://Scenes/Combat/Board/Entities/Player.tscn"

func _ready():
	%UI.visible = false
	
	if multiplayer.get_unique_id() == 1:
		var i = 0
		for key in MasterInfo.playerIDs.keys():
			var startingPoint = %Environment.getRandomStartPoint(i)
			var entityID = randi()
			
			%Environment.addEntity(playerScene, startingPoint, MasterInfo.playerIDs.get(key), key, entityID)
			
			for id in MasterInfo.playerIDs.keys():
				%Environment.addEntity.rpc_id(id, playerScene, startingPoint, MasterInfo.playerIDs.get(key), key, entityID)
		%Services.beginGame()
		
func _input(event):
	if(currentAction == actions.CARD):
		if event.is_action_pressed("rotate"):
			%Services.rotateAOE()
			%Services.checkMouseTargets(%Environment.getMouseTile())
			
		if event is InputEventMouseMotion:
			%Services.checkMouseTargets(%Environment.getMouseTile())
	
	if event.is_action_pressed("leftClick"):
		if(%Environment.getMouseTile() != Vector2i.MIN):
			
			match currentAction:
				actions.MOVING:
					if MasterInfo.singleplayer or multiplayer.get_unique_id() == 1:
						%Services.selectedMoveTo(%Environment.getMouseTile())
					else:
						%Services.remoteSelectedMoveTo.rpc_id(1, %Environment.getMouseTile())
			
				actions.CARD:
					if MasterInfo.singleplayer or multiplayer.get_unique_id() == 1:
						%Services.selectedUseCard(%Environment.getMouseTile())
					else:
						%Services.remoteSelectedUseCard.rpc_id(1, %Environment.getMouseTile(), %Services.selectedCard.packageToDict(), %Services.areaRotation)
				
	elif event.is_action_pressed("rightClick"):
		
		match currentAction:
			actions.MOVING:
				%Services.cancelMove()
				
			actions.CARD:
				%Services.cancelCard()
				
			actions.INSPECTING:
				%Services.cancelInspect()
				
			actions.STATUS:
				%Services.cancelStatus()
	
	elif event.is_action_pressed("escape"):
		
		match currentAction:
			actions.MOVING:
				%Services.cancelMove()
				
			actions.CARD:
				%Services.cancelCard()
				
			actions.INSPECTING:
				%Services.cancelInspect()
				
			actions.STATUS:
				%Services.cancelStatus()

#0: NONE, 1: SELECTING, 2: MOVING, 3: CARD, 4: INSPECTING, 5: STATUS
@rpc("any_peer")
func setAction(action : actions):
	currentAction = action
