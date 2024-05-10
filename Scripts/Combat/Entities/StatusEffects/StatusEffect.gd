extends Node
class_name StatusEffect

var statusName
var statusIcon
@export var timer = 3
@export var countdown = 0
@export var genericCounters = [0]

func _merge(effect):
	pass

func _onInflicted(entity):
	pass

func _onTurnStart(entity):
	pass

func _onTurnEnd(entity):
	pass

func _onRound(entity):
	pass

func _onDamage(entity, amount):
	return amount
