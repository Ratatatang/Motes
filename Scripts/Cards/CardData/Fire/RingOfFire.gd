extends FireCard

func _init():
	super()
	displayName = "Ring of Fire"
	name = "RingOfFire"
	description = "Ignites a circle of fire around a tile."
	castChance = 100
	cost = 9
	range = 5
	
	areaOfEffect = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)]
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (tile: Vector2i, entity: Entity, selfEntity: Entity):
		for tileIteration in areaOfEffect:
			MasterInfo.currentLevelMap.setTileData(tile+tileIteration, "res://Scripts/Combat/TileEffects/Burning.gd")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
