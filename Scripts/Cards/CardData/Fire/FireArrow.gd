extends FireCard

func _init():
	super()
	displayName = "Fire  Arrow"
	name = "FireArrow"
	description = "Launches a bolt of flame that does some damage, and ignites."
	castChance = 95
	cost = 5
	targeting = ["Enemies"]

func _OnEnemyEffect(target):
	target.damage(5)
