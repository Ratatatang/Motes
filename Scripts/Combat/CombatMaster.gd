extends Node2D

enum actions {
	NONE,
	SELECTING,
	MOVING,
	CARD,
	INSPECTING,
	STATUS,
	HISTORY
}

var currentAction = actions.NONE

var playerScene = "res://Scenes/Combat/Board/Entities/Player.tscn"
var enemyScene = "res://Scenes/Combat/Board/Entities/Enemy.tscn"

func _ready():
	%UI.visible = false
	
	if multiplayer.get_unique_id() == 1:
		var gamemode = MasterInfo.gameInfo[0]
		
		for id in MasterInfo.playerIDs.keys():
			
			if id == 0:
				continue
			
			var playerID = MasterInfo.playerIDs.get(id)
			var playerInfo = MasterInfo.gameInfo[1].get(id)
			var team
			var startingPoint
			
			match gamemode:
				"FreeForAll":
					team = playerID
					startingPoint = %Environment.getRandomStartPoint(randi_range(0, 4))
				"Teams":
					team = playerInfo[0]
					
					match team:
						"Red":
							startingPoint = %Environment.getRandomStartPoint(0)
						"Blue":
							startingPoint = %Environment.getRandomStartPoint(1)
						"Green":
							startingPoint = %Environment.getRandomStartPoint(2)
						"Yellow":
							startingPoint = %Environment.getRandomStartPoint(4)
			
			var entityID = randi()
			
			%Environment.addEntity.rpc(playerScene, startingPoint, id, team, entityID)
		
		%Environment.addEntity.rpc(playerScene, %Environment.getRandomStartPoint(0), 1, "teama", randi())
		
		if MasterInfo.playerIDs.has(0):
			
			var AIInfo = MasterInfo.gameInfo[1].get(0)
			var id = 0
			
			for AI in MasterInfo.playerIDs.get(0):
				var playerInfo = AIInfo[id]
				var team
				var startingPoint
			
				match gamemode:
					"FreeForAll":
						team = AI
						startingPoint = %Environment.getRandomStartPoint(randi_range(0, 4))
					"Teams":
						team = playerInfo[0]
					
						match team:
							"Red":
								startingPoint = %Environment.getRandomStartPoint(0)
							"Blue":
								startingPoint = %Environment.getRandomStartPoint(1)
							"Green":
								startingPoint = %Environment.getRandomStartPoint(2)
							"Yellow":
								startingPoint = %Environment.getRandomStartPoint(4)
			
				var entityID = randi()
			
				%Environment.addEntity.rpc(enemyScene, startingPoint, 0, team, entityID)
				
				id += 1
			
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
			
			actions.HISTORY:
				%Services.cancelHistory()
	
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
			
			actions.HISTORY:
				%Services.cancelHistory()

@rpc("any_peer")
func cardUsed(card):
	%AnimationCard.passEncoded.rpc(card)
	%AnimationCard.playUseCard.rpc()

#0: NONE, 1: SELECTING, 2: MOVING, 3: CARD, 4: INSPECTING, 5: STATUS, 6: HISTORY
@rpc("any_peer")
func setAction(action : actions):
	currentAction = action
	
	match currentAction:
		actions.SELECTING:
			%Camera.cameraLocked = false
			
		actions.MOVING:
			%Camera.cameraLocked = false
				
		actions.CARD:
			%Camera.cameraLocked = false
				
		actions.INSPECTING:
			%Camera.cameraLocked = true
				
		actions.STATUS:
			%Camera.cameraLocked = true
			
		actions.HISTORY:
			%Camera.cameraLocked = true
