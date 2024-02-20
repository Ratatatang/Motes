extends FireCard

func _init():
	super()
	displayName = "Fire  Arrow"
	name = "FireArrow"
	description = "Launches a bolt of flame that does some damage, and ignites."
	castChance = 95
	cost = 5
	range = 5
	
	AITags = ["Damage"]
	
	enemyEffect = func (tile: Vector2i, entity: Entity, selfEntity: Entity):
		entity.damage(5, "Fire")
	
	targeting = [enemyEffect]
	validTargets = ["Enemy"]
