extends StatusEffect

var maxHP = 12
var hp = 12
var shatter = 20

func _init():
	statusName = "Frozen"
	statusIcon = ""
	countdown = 1

func _onDamage(entity, amount):
	hp -= amount
	
	if(hp <= 0):
		hp = 0
		return shatter
		
	return 0

func _onTurnEnd(entity):
	if countdown == 0:
		entity.clearStatus(self)
	else:
		countdown -= 1
