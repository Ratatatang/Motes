extends TileEffect

func _init():
	effectName = "Blue Burning"
	bias = 5
	duration = 3

func _onSet(entity):
	entity.giveStatus("res://Scenes/Combat/Board/Entities/StatusEffects/onBlueFire.tscn")
	entity.damage(4, "Fire")

func _walkedOn(entity):
	entity.giveStatus("res://Scenes/Combat/Board/Entities/StatusEffects/onBlueFire.tscn")
	entity.damage(4, "Fire")
