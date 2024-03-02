extends Node2D

enum actions {
	NONE,
	SELECTING,
	MOVING,
	CARD,
	INSPECTING,
	STATUS
}
var currentAction = actions.NONE

func _ready():
	%Environment.addEntity(load("res://Scenes/Combat/Board/Entities/Player.tscn"), Vector2(13, 5))
	%Environment.addEntity(load("res://Scenes/Combat/Board/Entities/Player.tscn"), Vector2(21, 5))
	%Environment.addEntity(load("res://Scenes/Combat/Board/Entities/Enemy.tscn"), Vector2(23, 5), "Enemy1")
	%UI.visible = false
	%Services.beginGame()
	
func _input(event):
	if(currentAction == actions.CARD):
		if event is InputEventMouseMotion:
			%Services.checkMouseTargets(%Environment.getMouseTile())
	
	if event.is_action_pressed("leftClick"):
		if(%Environment.getMouseTile() != Vector2i.MIN):
			
			match currentAction:
				actions.MOVING:
					%Services.selectedMoveTo(%Environment.getMouseTile())
			
				actions.CARD:
					%Services.useCard(%Environment.getMouseTile())
				
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
