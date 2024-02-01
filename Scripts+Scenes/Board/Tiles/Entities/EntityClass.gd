extends CharacterBody2D
class_name Entity

@onready var tilemap : TileMap

var deck : Array[String]
var curDeck : Array[String]
var maxHandSize : int
var hand : Dictionary
var maxAP : int
var curAP : int
var maxHP : int
var curHP : int

var astarGrid : AStarGrid2D
var currentPath : Array[Vector2i]
var targetPosition : Vector2
var moving : bool
var otherEntities

func _ready():
#	currentPath = [Vector2i(0,0)]
	astarGrid = AStarGrid2D.new() 
	astarGrid.region = tilemap.get_used_rect()
	astarGrid.cell_size = Vector2(64, 64)
	astarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astarGrid.update()
	updateImpassable()

func _physics_process(delta):
	if(currentPath.is_empty()):
		pass
	else:
		if moving:
			targetPosition = tilemap.map_to_local(currentPath.front())
			moving = true
			
		global_position = global_position.move_toward(targetPosition, 1)
		
		if(global_position == targetPosition):
			updateImpassable()
			currentPath.pop_front()
		
		if(currentPath.is_empty() == false):
			targetPosition = tilemap.map_to_local(currentPath.front())
		else:
			moving = false

func setPath(desiredPoint):
	var idPath = []
	
	if moving:
		pass
	else:
		idPath = astarGrid.get_id_path(
			tilemap.local_to_map(global_position), 
			tilemap.local_to_map(desiredPoint))
		
	if idPath.is_empty() == false && currentPath.size() < 1:
		currentPath = idPath

func updateImpassable():
	for x in tilemap.get_used_rect().size.x:
		for y in tilemap.get_used_rect().size.y:
			
			var tilePos = Vector2i(
			x + tilemap.get_used_rect().position.x,
			y + tilemap.get_used_rect().position.y)
			
			var tileData = tilemap.get_cell_tile_data(0, tilePos)
			
			if tileData == null or tileData.get_custom_data("impassable") == true:
				astarGrid.set_point_solid(tilePos)
			else:
				astarGrid.set_point_solid(tilePos, false)
	
	for entity in otherEntities:
		astarGrid.set_point_solid(tilemap.local_to_map(entity.global_position))

func incrementAP(num : int) -> void:
	curAP += num
	
func enoughAP(cost : int) -> bool:
	if(cost <= curAP):
		return true
	else:
		return false
