extends WaterCard

func _init():
	super()
	displayName = "Icicle  Lance"
	name = "IceLance"
	description = "A long spear of ice that inflicts heavy damage."
	expandedDescription = "A long spear of ice.[/center]\n\n[center]Does 8 Water damage to an enemy."
	castChance = 100
	cost = 6
	range = 4
	
	AITags = ["Damage"]
	
	enemyEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		_entity.damage(8, "Water")
	
	tileDataEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		for effect in _tileEffect:
			if effect.destructable:
				effect.damage(5, "Water")
	
	targeting = [enemyEffect, tileDataEffect]
	validTargets = ["Enemy", "Destructable"]
