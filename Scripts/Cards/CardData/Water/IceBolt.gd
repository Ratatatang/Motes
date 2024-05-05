extends WaterCard

func _init():
	super()
	displayName = "Ice  Bolt"
	name = "IceBolt"
	description = "A volley of ice that does some damage."
	expandedDescription = "A volley of ice.[/center]\n\n[center]Does 5 Water damage to an enemy."
	castChance = 100
	cost = 3
	range = 4
	
	AITags = ["Damage"]
	
	enemyEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		_entity.damage(5, "Water")
		
	tileDataEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		for effect in _tileEffect:
			if effect.destructable:
				effect.damage(5, "Water")
	
	targeting = [enemyEffect, tileDataEffect]
	validTargets = ["Enemy", "Destructable"]
