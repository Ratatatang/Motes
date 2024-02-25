extends Node2D

enum actions {
	NONE,
	SELECTING,
	MOVING,
	CARD,
	INSPECTING
}
var currentAction = actions.NONE

func _ready():
	%Environment.addEntity(load("res://Scenes/Combat/Board/Entities/Player.tscn"), Vector2(13, 5))
	#%Environment.addEntity(load("res://Scenes/Combat/Board/Entities/Player.tscn"), Vector2(21, 5))
	%Environment.addEntity(load("res://Scenes/Combat/Board/Entities/Enemy.tscn"), Vector2(23, 5), "Enemy1")
	%UI.visible = false
	%Services.beginGame()
	
func _input(event):
	if(currentAction == actions.CARD):
		if event is InputEventMouseMotion:
			%Services.checkMouseTargets(%Environment.getMouseTile())
	
	if event.is_action_pressed("leftClick"):
		if(%Environment.getMouseTile() != Vector2i.MIN):
			
			if(currentAction == actions.MOVING):
				%Services.selectedMoveTo(%Environment.getMouseTile())
			
			if(currentAction == actions.CARD):
					%Services.useCard(%Environment.getMouseTile())
				
	elif event.is_action_pressed("rightClick"):
		if(currentAction == actions.MOVING):
			%Services.cancelMove()
			
		if(currentAction == actions.CARD):
			%Services.cancelCard()
		if(currentAction == actions.INSPECTING):
			%Services.cancelInspect()

#0: NONE, 1: SELECTING, 2: MOVING, 3: CARD, 4: INSPECTING
func setAction(action : actions):
	currentAction = action
