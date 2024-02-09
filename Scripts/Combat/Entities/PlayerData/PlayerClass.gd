extends Entity
class_name PlayerPawn

func _init():
	deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "FireArrow"]
	maxHandSize = 8
	maxAP = 30
	maxHP = 20

#func _input(event):
#	if(event.is_action_pressed("leftClick")):
#		setPath(map.getMouseTile())
