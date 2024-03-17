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
	
	if multiplayer.is_server():
		var i = 0
		for key in MasterInfo.playerIDs.keys():
			var startingPoint = %Environment.getRandomStartPoint(i)
			%Environment.addEntity(playerScene, startingPoint, MasterInfo.playerIDs.get(key))
		
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
						%Services.selectedMoveTo.rpc_id(1, %Environment.getMouseTile())
			
				actions.CARD:
					%Services.selectedUseCard(%Environment.getMouseTile())
				
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
func setAction(action : actions):
	currentAction = action
