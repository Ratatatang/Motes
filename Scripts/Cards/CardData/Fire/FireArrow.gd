extends FireCard

func _init():
	super()
	displayName = "Fire  Arrow"
	name = "FireArrow"
	description = "An arrow of flame that does some damage."
	expandedDescription = "An arrow of flame.[/center]\n\n[center]Does 5 Fire damage to an enemy."
	castChance = 100
	cost = 3
	range = 4
	
	AITags = ["Damage"]
	
	enemyEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		_entity.damage(5, "Fire")
		
	tileDataEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int, _tileEffect : Array):
		for effect in _tileEffect:
			if effect.destructable:
				effect.damage(5, "Water")
	
	targeting = [enemyEffect, tileDataEffect]
	validTargets = ["Enemy", "Destructable"]
