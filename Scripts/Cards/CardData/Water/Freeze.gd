extends WaterCard

func _init():
	super()
	displayName = "Freeze"
	name = "Freeze"
	description = "Temporarily freezes a target"
	expandedDescription = "Freezes a target until the end of their turn.\n\n15 frozen health, Shatters for 25"
	castChance = 100
	cost = 4
	range = 4
	
	AITags = ["Damage", "Freeze"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		pass
	
	targeting = [enemyEffect]
	validTargets = ["Enemy"]
