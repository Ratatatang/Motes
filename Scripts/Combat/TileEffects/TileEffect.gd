extends Node2D
class_name TileEffect

var effectName : String

@export var duration : int
@export var timer : int = 0
@export var bias : int = 0
@export var curHP : int
@export var maxHP : int

var impassable = false
var destructable = false

func merge(data):
	pass

func _onSet(entity):
	pass

func _adjacentEntity(entity):
	pass

func _walkedOn(entity):
	pass

func advanceTimer():
	timer += 1
	
	if timer >= duration:
		freeTileData()

func damage(damageAmount, type) -> void:
	curHP -= damageAmount
	GlobalFX.displayDamageNumber(damageAmount, global_position, type)
	
	if(curHP <= 0):
		curHP = 0
		freeTileData()

func freeTileData():
	MasterInfo.currentLevelMap.removeDataFromTile(self)
	queue_free()
