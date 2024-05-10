extends WaterCard

func _init():
	super()
	displayName = "Freeze"
	name = "Freeze"
	description = "Temporarily freezes a target"
	expandedDescription = "Freezes a target until the end of their turn, or their next turn if the caster freezes themself.\n\nMovement speed is halved while frozen\n\n12 frozen health, Shatters for 20"
	castChance = 100
	cost = 4
	range = 4
	
	AITags = ["Damage", "Freeze"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		if _entity == _selfEntity:
			_entity.giveStatus("res://Scripts/Combat/Entities/StatusEffects/SelfFrozen.gd")
		else:
			_entity.giveStatus("res://Scripts/Combat/Entities/StatusEffects/Frozen.gd")
	
	targeting = [enemyEffect]
	validTargets = ["Enemy"]
