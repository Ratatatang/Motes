extends FireCard

func _init():
	super()
	displayName = "Fire  Arrow"
	name = "FireArrow"
	description = "A bolt of flame that does some damage."
	expandedDescription = "A bolt of flame.[/center]\n\n[center]Does 5 Fire damage to an enemy."
	castChance = 100
	cost = 3
	range = 3
	
	AITags = ["Damage"]
	
	enemyEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity):
		_entity.damage(5, "Fire")
	
	targeting = [enemyEffect]
	validTargets = ["Enemy"]
