extends StatusEffect

func _init():
	statusName = "Burning"
	statusIcon = "res://Assets/UI/StatusIcons/Burning.png"

func _onTurnStart(entity):
	entity.damage(2, "Fire")
	
	if countdown == timer:
		entity.clearStatus(self)

func _onTurnEnd(entity):
	entity.damage(2, "Fire")
	countdown += 1
