extends Entity
class_name EnemyPawn

signal advanceMoves

var movesList = []
var averageHandSize
var minHandSize

enum possibleMoves {
	MOVE,
	DRAW,
	CARD,
}

func _init():
	isAI = true
	deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "FireArrow", "FireArrow", "FireArrow", "FireArrow", "FireArrow"]
	maxHandSize = 8
	maxAP = 30
	maxHP = 20
	
	averageHandSize = (maxHandSize/2)+1
	minHandSize = (maxHandSize/2)-2
	clamp(minHandSize, 1, MasterInfo.INT_MAX)
	
	super()

func decideMoves():
	var selfTile = map.getEntityTile(self)
	var APCost = 0
	var averageRange
	
	"""#Initial draw up to min amount of cards
	if hand.size() <= minHandSize:
		movesList.append([possibleMoves.DRAW, abs(hand.size()-minHandSize)])"""
	
	#await advanceMoves
	
	averageRange = calculateAverageRange()
	
	var minDistance = 0
	var closestPath
	var closestTarget
	for target in map.getEntities():
		if(target != self):
			if(target.team != team):
				
				var pathTo = characterPassableMap.get_id_path(selfTile, map.getEntityTile(target))
				
				if(minDistance >= pathTo.size() or closestPath == null):
					minDistance = pathTo.size()
					closestTarget = target
					closestPath = pathTo
	
	closestPath.resize(minDistance-averageRange)
	#if closest target is not already in range, else move to the target
	currentPath = closestPath

func calculateAverageRange(cards = hand) -> int:
	var averageRange = 0

	for card in cards:
		averageRange += card.range
	
	averageRange /= cards.size()
	return averageRange
