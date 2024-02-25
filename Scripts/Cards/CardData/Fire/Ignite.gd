extends FireCard

func _init():
	super()
	displayName = "Ignite"
	name = "Ignite"
	description = "Lights a tile and anything on it on fire."
	expandedDescription = "Lights a tile and anything on it on fire for 3 turns."
	castChance = 100
	cost = 3
	range = 4
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity):
		MasterInfo.currentLevelMap.setTileData(_tile, "res://Scripts/Combat/TileEffects/Burning.gd")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
