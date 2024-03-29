extends Node2D
class_name TileEffect

var effectName : String

@export var duration : int
@export var bias : int = 0

func merge(data):
	pass

func _onSet(entity):
	pass

func _adjacentEntity(entity):
	pass

func _walkedOn(entity):
	pass
