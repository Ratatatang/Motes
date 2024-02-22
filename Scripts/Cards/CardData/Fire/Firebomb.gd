extends FireCard

func _init():
	super()
	displayName = "Firebomb"
	name = "Firebomb"
	description = "Lights a cross of tiles ablaze for 3 turns"
	castChance = 100
	cost = 7
	range = 5
	
	areaOfEffect = [Vector2i.ZERO, Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (tile: Vector2i, entity: Entity, selfEntity: Entity):
		for tileIteration in areaOfEffect:
			MasterInfo.currentLevelMap.setTileData(tile+tileIteration, "res://Scripts/Combat/TileEffects/Burning.gd")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
