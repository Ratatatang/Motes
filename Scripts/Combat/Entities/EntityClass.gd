extends CharacterBody2D
class_name Entity

signal finishedMoving

@export var speed : int = 8

@export var deck : Array[String]
@export var curDeck : Array[String]
var hand : Array = []
@export var maxHandSize : int = 8
@export var maxAP : int = 30
@export var curAP : int
@export var maxHP : int = 20
@export var curHP : int

@export var packagedHand : Array = []

@onready var ray = $RayCast2D
@onready var rayNW = $RayCast2D2
@onready var rayNE = $RayCast2D3
@onready var raySW = $RayCast2D4
@onready var raySE = $RayCast2D5
@onready var rays = [ray, rayNW, rayNE, raySW, raySE]

var map : LevelMap

var AStarGrid : AStarGrid2D
var AStarGridAI : AStarGrid2D
var characterPassableMap : AStarGrid2D

var currentPath : Array[Vector2i]
var targetPosition : Vector2
var moving : bool

@export var team : String
@export var isAI : bool = false
@export var entityID : int
var parentID : int

@export var statusEffects = []
@export var firstTile = true 

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
			
			if(multiplayer.get_unique_id() == 1):
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
	hand.append(load(MasterInfo.cardsRefrence.get(curDeck.pop_front())).new())
	packagedHand.append(hand.back().packageToDict())

func setRaysTarget(point) -> void:
	for raycast in rays:
		raycast.target_position = (point*64)-Vector2i(position)
		raycast.force_raycast_update()
		
func canTargetTile(point, targeting, LOS = true) -> bool:
	
	if(LOS):
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
		
		elif(target == "Destructable"):
			var tileEffects = map.getTileData(point)
			
			if tileEffects != null:
				for effect in tileEffects:
					if effect.destructable:
						return true
			
	return false

func canSeeTile(point) -> bool:
	setRaysTarget(point)
	
	if(ray.is_colliding() and rayNE.is_colliding() and rayNW.is_colliding() and raySE.is_colliding() and raySW.is_colliding()):
		return false
	return true

func giveStatus(status):
	var statusNode = load(status).instantiate()
	
	for effect in statusEffects:
		if effect.statusName == statusNode.statusName:
			effect._merge(status)
			return
	
	add_child(statusNode)
	statusEffects.append(statusNode)
	
	if multiplayer.get_unique_id() == 1:
		giveStatusRemote.rpc(status)
	
	GlobalFX.displayInflictedText("Inflicted with " + statusNode.statusName+"!", global_position)
	statusNode._onInflicted(self)

@rpc("any_peer")
func giveStatusRemote(status):
	var statusNode = load(status).instantiate()
	
	add_child(statusNode)
	statusEffects.append(statusNode)

func clearStatus(status):
	for effect in statusEffects:
		if effect.statusName == status.statusName:
			statusEffects.erase(status)
			status.queue_free()
			return

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

func heal(healAmount) -> void:
	curHP += healAmount
	GlobalFX.displayHealNumber(healAmount, global_position)
	
	if(curHP > maxHP):
		curHP = maxHP

func damage(damageAmount, type) -> void:
	var trueDamage = damageAmount
	
	for effect in statusEffects:
		trueDamage = effect._onDamage(self, damageAmount)
	
	curHP -= trueDamage
	GlobalFX.displayDamageNumber(trueDamage, global_position, type)
	
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
