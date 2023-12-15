extends CharacterBody2D
class_name CharacterClass

@onready var tilemap : TileMap
@onready var line = $Line2D

var deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "FireArrow"]
var curDeck = deck.duplicate()
var maxHandSize = 8
var hand = {}
var maxAP = 30
var curAP = 30
var maxHP = 20
var curHP = 20

var astarGrid : AStarGrid2D
var currentPath : Array[Vector2i]
var linePath : Array[Vector2i]
var targetPosition : Vector2
var moving : bool

func _ready():
#	currentPath = [Vector2i(0,0)]
	astarGrid = AStarGrid2D.new() 
	astarGrid.region = tilemap.get_used_rect()
	astarGrid.cell_size = Vector2(64, 64)
	astarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astarGrid.update()
	
	for x in tilemap.get_used_rect().size.x:
		for y in tilemap.get_used_rect().size.y:
			
			var tilePos = Vector2i(
			x + tilemap.get_used_rect().position.x,
			y + tilemap.get_used_rect().position.y)
			
			var tileData = tilemap.get_cell_tile_data(0, tilePos)
			
			if tileData == null or tileData.get_custom_data("impassable") == true:
				astarGrid.set_point_solid(tilePos)

func enableLine():
	line.visible = true
	$ColorRect.color = "f00000"

func disableLine():
	line.visible = false
	$ColorRect.color = "990000"

func pathToMouse() -> Array[Vector2i]:
	var idPath = []
	
	if moving:
		pass
	else:
		idPath = astarGrid.get_id_path(
			tilemap.local_to_map(global_position), 
			tilemap.local_to_map(get_global_mouse_position()))
	
	return idPath

func setPath():
	var idPath = []
	
	if moving:
		pass
	else:
		idPath = astarGrid.get_id_path(
			tilemap.local_to_map(global_position), 
			tilemap.local_to_map(get_global_mouse_position()))
		
	if idPath.is_empty() == false && currentPath.size() < 1:
		currentPath = idPath

func _physics_process(delta):
	if(currentPath.is_empty()):
		pass
	else:
		if moving:
			targetPosition = tilemap.map_to_local(currentPath.front())
			moving = true
			
		global_position = global_position.move_toward(targetPosition, 1)
		
		if(global_position == targetPosition):
			currentPath.pop_front()
		
		if(currentPath.is_empty() == false):
			targetPosition = tilemap.map_to_local(currentPath.front())
		else:
			moving = false
		
	if(linePath != pathToMouse()):
		line.clear_points()
		linePath = pathToMouse()
		line.position =- (global_position-Vector2(32,32))
		for point in linePath:
			line.add_point(tilemap.map_to_local(point)-Vector2(32,32))

func incrementAP(num : int) -> void:
	curAP += num
	
func enoughAP(cost : int) -> bool:
	if(cost <= curAP):
		return true
	else:
		return false


