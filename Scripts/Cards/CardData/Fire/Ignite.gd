extends FireCard

func _init():
	super()
	displayName = "Ignite"
	name = "Ignite"
	description = "Lights a tile and anything on it on fire."
	expandedDescription = "Lights a tile and anything on it on fire for 3 turns."
	castChance = 100
	cost = 3
	range = 5
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int):
		MasterInfo.currentLevelMap.setTileData(_tile, "res://Scenes/Combat/Board/Tiles/Effects/orangeFlame.tscn")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
