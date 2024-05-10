extends FireCard

func _init():
	super()
	displayName = "Firewall"
	name = "Firewall"
	description = "Create a wall of flame 3 tiles long."
	expandedDescription = "Create a wall of flame 3 tiles long that burns for 3 rounds."
	castChance = 100
	cost = 6
	range = 4
	
	AOERotations = true
	areaOfEffect = [[Vector2i.ZERO, Vector2i(0, 1), Vector2i(0, -1)], [Vector2i.ZERO, Vector2i(1, 0), Vector2i(-1, 0)]]
	
	AITags = ["Damage", "Ignite"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		for tileIteration in areaOfEffect[currentRotation]:
			if(_selfEntity.canTargetTile(_tile+tileIteration, validTargets, false)):
				MasterInfo.currentLevelMap.setTileData(_tile+tileIteration, "res://Scenes/Combat/Board/Tiles/Effects/orangeFlame.tscn")
	
	targeting = [tileEffect]
	validTargets = ["Tile"]
