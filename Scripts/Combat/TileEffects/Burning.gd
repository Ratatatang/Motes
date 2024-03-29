extends TileEffect

func _init():
	effectName = "Burning"
	bias = 5

func _onSet(entity):
	entity.giveStatus("res://Scenes/Combat/Board/Entities/StatusEffects/onFire.tscn")
	entity.damage(2, "Fire")

func _walkedOn(entity):
	entity.giveStatus("res://Scenes/Combat/Board/Entities/StatusEffects/onFire.tscn")
	entity.damage(2, "Fire")
