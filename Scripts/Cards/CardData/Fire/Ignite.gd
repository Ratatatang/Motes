extends FireCard

func _init():
	super()
	displayName = "Ignite"
	name = "Ignite"
	description = "Lights a tile on fire or the enemy on the tile for 3 turns."
	castChance = 100
	cost = 5
	range = 5
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (tile: Vector2i, entity: Entity, selfEntity: Entity):
		MasterInfo.currentLevelMap.setTileData(tile, "res://Scripts/Combat/TileEffects/Burning.gd")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
