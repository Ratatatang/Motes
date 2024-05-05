extends Node2D
class_name TileEffect

var effectName : String

@export var duration : int
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

func damage(damageAmount, type) -> void:
	curHP -= damageAmount
	GlobalFX.displayDamageNumber(damageAmount, global_position, type)
	
	if(curHP <= 0):
		curHP = 0
		queue_free()
