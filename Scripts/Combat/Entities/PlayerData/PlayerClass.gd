extends Entity
class_name PlayerPawn

@onready var line = $Line2D

func _init():
	deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "Firebomb", "Firebomb", "Firebomb", "RingOfFire", "RingOfFire", "Firewall", "Firewall"]
	#deck = ["Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze", "Freeze"]
	maxHandSize = 8
	maxAP = 30
	maxHP = 20
	super()

func _physics_process(delta):
	super(delta)
	
	if(line.visible and !moving):
		line.clear_points()
		
		for point in getPath(map.getMouseTile()):
			line.add_point((point*64)-Vector2i(position))

func invalidMovement() -> void:
	$AnimationPlayer.play("invalidMovement")

func enableLine() -> void:
	line.visible = true
	$AnimationPlayer.play("reset")

func disableLine() -> void:
	line.visible = false 
