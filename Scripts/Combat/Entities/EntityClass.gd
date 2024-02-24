extends CharacterBody2D
class_name Entity

signal finishedMoving

@export var speed = 1

@export var deck : Array[String]
var curDeck : Array[String]
var hand : Array = []
@export var maxHandSize : int = 8
@export var maxAP : int = 30
var curAP : int
@export var maxHP : int = 20
var curHP : int

@onready var ray = $RayCast2D
@onready var rayNW = $RayCast2D2
@onready var rayNE = $RayCast2D3
@onready var raySW = $RayCast2D4
@onready var raySE = $RayCast2D5
@onready var rays = [ray, rayNW, rayNE, raySW, raySE]

var map : LevelMap
var cardsRef : Dictionary

var AStarGrid : AStarGrid2D
var AStarGridAI : AStarGrid2D
var characterPassableMap : AStarGrid2D

var currentPath : Array[Vector2i]
var targetPosition : Vector2
var moving : bool

var team : String
var isAI : bool = false

var statusEffects = []
var firstTile = true

func _init():
	curDeck = deck.duplicate()
	curDeck.shuffle()
	curAP = maxAP
	curHP = maxHP

func _physics_process(delta):
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
			
			if(!firstTile):
				var tileEffects = map.getTileData(Vector2i(position/64))
				
				if(tileEffects != null):
					for effect in tileEffects:
						effect._walkedOn(self)
			else:
				firstTile = false
		
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
		firstTile = true
		currentPath = idPath

func isPassablePoint(point) -> bool:
	var tileData = map.get_cell_tile_data(0, point)
	
	if tileData == null or tileData.get_custom_data("impassable") == true:
		return false
	return true
	
func getPath(desiredPoint) -> Array[Vector2i]:
	return AStarGrid.get_id_path(map.getEntityTile(self), desiredPoint)

func drawCard() -> void:
	hand.append(load(cardsRef.get(curDeck.pop_front())).new())
	
func setRaysTarget(point) -> void:
	for raycast in rays:
		raycast.target_position = (point*64)-Vector2i(position)
		raycast.force_raycast_update()
		
func canTargetTile(point, targeting) -> bool:
	setRaysTarget(point)
	
	if(ray.is_colliding() and rayNE.is_colliding() and rayNW.is_colliding() and raySE.is_colliding() and raySW.is_colliding()):
		return false
				
	for target in targeting:
		if(target == "Tile"):
			var tileData = map.get_cell_tile_data(0, point)
			
			if tileData != null:
				if tileData.get_custom_data("impassable") == false:
					return true
			
		elif(target == "Enemy"):
			var tileEntity = map.getTileEntity(point)
			if(tileEntity != null):
				if(tileEntity.team != team):
					return true
			
	return false

func canSeeTile(point) -> bool:
	setRaysTarget(point)
	
	if(ray.is_colliding() and rayNE.is_colliding() and rayNW.is_colliding() and raySE.is_colliding() and raySW.is_colliding()):
		return false
	return true

func giveStatus(status):
	for effect in statusEffects:
		if effect.statusName == status.statusName:
			effect._merge(status)
			return
	statusEffects.append(status)
	status._onInflicted(self)

func clearStatus(status):
	statusEffects.erase(status)

func checkTurnStartEffects():
	for effect in statusEffects:
		effect._onTurnStart(self)

func checkTurnEndEffects():
	for effect in statusEffects:
		effect._onTurnEnd(self)

func checkRoundEffects():
	for effect in statusEffects:
		effect._onRound(self)

func getMovementPoints() -> Array:
	return currentPath

func setTeam(newTeam : String) -> void:
	team = newTeam

func damage(damageAmount, type) -> void:
	curHP -= damageAmount
	GlobalFX.displayDamageNumber(damageAmount, global_position)
	
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

func refreshAP() -> void:
	incrementAP(maxAP/2)
