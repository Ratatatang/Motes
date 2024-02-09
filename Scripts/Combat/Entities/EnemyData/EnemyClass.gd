extends Entity
class_name EnemyAI

var movesList = []

enum possibleMoves {
	MOVE,
	DRAW,
	USEATTACK,
}

func _init():
	isAI = true
	deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "FireArrow"]
	maxHandSize = 8
	hand = {}
	maxAP = 30
	maxHP = 20

func decideMoves():
	pass
