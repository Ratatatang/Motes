extends FireCard

func _init():
	super()
	displayName = "Firebomb"
	name = "Firebomb"
	description = "A ball of fire. lights a cross of tiles ablaze."
	expandedDescription = "A ball of fire and rocks.\n\nLights a cross of tiles ablaze for 3 turns."
	castChance = 100
	cost = 5
	range = 3
	
	areaOfEffect = [Vector2i.ZERO, Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity):
		for tileIteration in areaOfEffect:
			if(_selfEntity.canTargetTile(_tile+tileIteration, validTargets)):
				MasterInfo.currentLevelMap.setTileData(_tile+tileIteration, "res://Scripts/Combat/TileEffects/Burning.gd")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
