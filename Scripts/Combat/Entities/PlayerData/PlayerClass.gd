extends Entity
class_name PlayerPawn

@onready var line = $Line2D

func _init():
	deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "FireArrow"]
	maxHandSize = 8
	maxAP = 30
	maxHP = 20
	super()

func _physics_process(delta):
	super(delta)
	
	if(line.visible):
		line.clear_points()
		
		for point in getPath(map.getMouseTile()):
			line.add_point((point*64)-Vector2i(position))

func enableLine() -> void:
	line.visible = true

func disableLine() -> void:
	line.visible = false
