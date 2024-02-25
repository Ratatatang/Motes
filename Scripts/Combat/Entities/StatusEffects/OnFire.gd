extends StatusEffect

func _init():
	statusName = "Burning"

func _onTurnStart(entity):
	entity.damage(1, "Fire")
	
	if countdown == timer:
		entity.clearStatus(self)

func _onTurnEnd(entity):
	entity.damage(1, "Fire")
	countdown += 1
