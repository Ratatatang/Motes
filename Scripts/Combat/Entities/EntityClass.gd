extends CharacterBody2D
class_name Entity

signal finishedMoving

@export var deck : Array[String]
var curDeck : Array[String]
@export var maxHandSize : int = 8
@export var maxAP : int = 30
var curAP : int
@export var maxHP : int = 20
var curHP : int

var map : LevelMap

var AStarGrid : AStarGrid2D
var currentPath : Array[Vector2i]
var targetPosition : Vector2
var moving : bool

func _ready():
	curDeck = deck.duplicate()
	curAP = maxAP
	curHP = maxHP

func _physics_process(delta):
	$RayCast2D.target_position = get_local_mouse_position()-Vector2(32, 32)
	
	if(currentPath.is_empty()):
		pass
	else:
		if moving:
			targetPosition = currentPath.front()*64
			moving = true
			
		position = position.move_toward(targetPosition, 1)
		
		if(position == targetPosition):
			currentPath.pop_front()
			map.removeTileEntity(self)
			map.setTileEntity(Vector2i(position/64), self)
		
		if(currentPath.is_empty() == false):
			targetPosition = currentPath.front()*64
		else:
			moving = false
			finishedMoving.emit()

func setPath(desiredPoint) -> void:
	var idPath = []
	
	if moving:
		pass
	else:
		
		idPath = AStarGrid.get_id_path(
			map.getEntityTile(self), 
			desiredPoint)
		
	if idPath.is_empty() == false and currentPath.size() < 1:
		currentPath = idPath

func getMovementPoints() -> Array:
	return currentPath

func damage(damageAmount) -> void:
	curHP -= damageAmount
	
	if(curHP <= 0):
		curHP = 0
		queue_free()

func incrementAP(num : int) -> void:
	curAP += num
	if(curAP > maxAP):
		curAP = maxAP

func decrementAP(num : int) -> void:
	curAP -= num
	if(curAP < 0):
		curAP = 0

func enoughAP(cost : int) -> bool:
	if(abs(cost) <= curAP):
		return true
	return false
