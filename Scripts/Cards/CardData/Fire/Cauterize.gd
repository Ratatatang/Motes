extends FireCard

func _init():
	super()
	displayName = "Cauterize"
	name = "Cauterize"
	description = "Either heals or damages the target by 5, depending on their HP"
	expandedDescription = "Uses fire on a targe.\n\nIf the target is above 50% HP, it deals 5 damage.\n\nIf the target is below 50% HP, it heals 5."
	castChance = 100
	cost = 5
	range = 1
	
	AITags = ["Damage"]
	
	enemyEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		if(_entity.curHP > _entity.maxHP/2):
			_entity.damage(5, "Fire")
		elif(_entity.curHP <= _entity.maxHP/2):
			_entity.heal(5)
	
	targeting = [enemyEffect]
	validTargets = ["Enemy"]
