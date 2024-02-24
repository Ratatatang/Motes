extends TileEffect

func _init():
	name = "Burning"
	VFX = "res://Scenes/Combat/Board/Tiles/FX/orangeFlame.tscn"
	bias = 5

func _onSet(entity):
	entity.giveStatus(load("res://Scripts/Combat/Entities/StatusEffects/OnFire.gd").new())
	entity.damage(2, "Fire")

func _walkedOn(entity):
	entity.giveStatus(load("res://Scripts/Combat/Entities/StatusEffects/OnFire.gd").new())
	entity.damage(2, "Fire")
