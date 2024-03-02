extends FireCard

func _init():
	super()
	displayName = "Cauterize"
	name = "Cauterize"
	description = "Either heals or damages the target by 5, depending on if they're below or above 50% HP"
	expandedDescription = "Burns a target.\n\nIf the target is above 50% HP, it deals 5 damage.\n\nIf the target is below 50% HP, it heals 5."
	castChance = 100
	cost = 5
	range = 5
	
	AITags = ["Damage"]
	
	enemyEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity):
		if(_entity.curHP > _entity.maxHP/2):
			_entity.damage(5, "Fire")
		elif(_entity.curHP <= _entity.maxHP/2):
			_entity.heal(5)
	
	targeting = [enemyEffect]
	validTargets = ["Enemy"]
