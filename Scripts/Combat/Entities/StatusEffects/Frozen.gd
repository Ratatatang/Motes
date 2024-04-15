extends StatusEffect

func _init():
	statusName = "Frozen"
	statusIcon = ""

func _onTurnStart(entity):
	entity.clearStatus(self)
