extends WaterCard

func _init():
	super()
	displayName = "Wall of ice"
	name = "IceWall"
	description = "Raise a solid wall of ice 3 tiles long."
	expandedDescription = "Raises a pillar of ice.\n\nThe pillar is an impassable wall that will last for 4 rounds."
	castChance = 100
	cost = 7
	range = 4
	
	AOERotations = true
	areaOfEffect = [[Vector2i.ZERO, Vector2i(0, 1), Vector2i(0, -1)], [Vector2i.ZERO, Vector2i(1, 0), Vector2i(-1, 0)]]
	
	AITags = ["Wall"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		for tileIteration in areaOfEffect[currentRotation]:
			if(_selfEntity.canTargetTile(_tile+tileIteration, validTargets, false)):
				MasterInfo.currentLevelMap.setTileData(_tile+tileIteration, "res://Scenes/Combat/Board/Tiles/Effects/IceWall.tscn")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
