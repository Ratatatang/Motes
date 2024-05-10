extends WaterCard

func _init():
	super()
	displayName = "Cryo  Aegis"
	name = "CryoAegis"
	description = "Defensively freeze a target"
	expandedDescription = "Freezes a target until the end of their turn, or their next turn if the caster freezes themself.\n\n30 frozen health, Shatters for 20"
	castChance = 100
	cost = 4
	range = 4
	
	AITags = ["Damage", "Freeze"]
	
	tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		pass
	
	targeting = [enemyEffect]
	validTargets = ["Enemy"]
