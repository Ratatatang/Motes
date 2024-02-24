extends FireCard

func _init():
	super()
	displayName = "Firewall"
	name = "Firewall"
	description = "Create a wall of flame 3 tiles long that burns for 3 turns."
	castChance = 100
	cost = 6
	range = 5
	
	areaOfEffect = [Vector2i.ZERO, Vector2i(0, 1), Vector2i(0, -1)]
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (tile: Vector2i, entity: Entity, selfEntity: Entity):
		for tileIteration in areaOfEffect:
			MasterInfo.currentLevelMap.setTileData(tile+tileIteration, "res://Scripts/Combat/TileEffects/Burning.gd")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
