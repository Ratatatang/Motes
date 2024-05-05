extends WaterCard

func _init():
	super()
	displayName = "Ice  Pillar"
	name = "IcePillar"
	description = "Raise a pillar of ice to block off a tile."
	expandedDescription = "Raises a pillar of ice.\n\nThe pillar is an impassable wall that will last for 5 turns."
	castChance = 100
	cost = 4
	range = 4
	
	AITags = ["Wall"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		MasterInfo.currentLevelMap.setTileData(_tile, "res://Scenes/Combat/Board/Tiles/Effects/IceWall.tscn")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
