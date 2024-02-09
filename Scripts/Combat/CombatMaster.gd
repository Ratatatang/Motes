extends Node2D

enum actions {
	NONE,
	SELECTING,
	MOVING
}
var currentAction = actions.NONE

func _ready():
	addEntity("res://Scenes/Combat/Board/Entities/Player.tscn")
	%UI.visible = false

func _input(event):
	if event.is_action_pressed("leftClick"):
		var tileEntity = %Environment.getTileEntity(%Environment.getMouseTile())
		
		if(tileEntity != null):
			
			if(currentAction == actions.NONE):
				%Services.loadCharacter(tileEntity)
				currentAction = actions.SELECTING
				
			elif(currentAction == actions.SELECTING and %Services.selectedCharacter == tileEntity):
				%Services.unloadCharacter()
				currentAction = actions.NONE
			
		else:
			if(currentAction == actions.MOVING):
				%Services.selectedMoveTo(%Environment.getMouseTile())

func addEntity(entity):
	%Environment.addEntity(load(entity), Vector2(20, 5))

#0: NONE, 1: SELECTING, 2: MOVING
func setAction(action : actions):
	currentAction = action
