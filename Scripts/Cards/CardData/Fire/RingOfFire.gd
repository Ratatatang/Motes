extends FireCard

func _init():
	super()
	displayName = "Ring of Fire"
	name = "RingOfFire"
	description = "Ignites a circle of fire around a tile."
	expandedDescription = "Ignites a circle of fire around a tile for 3 turns."
	castChance = 100
	cost = 7
	range = 3
	
	areaOfEffect = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)]
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int):
		for tileIteration in areaOfEffect:
			if(_selfEntity.canTargetTile(_tile+tileIteration, validTargets)):
				MasterInfo.currentLevelMap.setTileData(_tile+tileIteration, "res://Scripts/Combat/TileEffects/Burning.gd")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
