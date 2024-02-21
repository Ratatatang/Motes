extends Entity
class_name EnemyPawn

signal advanceMoves
signal movesReady

var AISteps = [func ():
				decideDrawMin(),
				func ():
				decideMove(),
				func ():
				decideUseCards(),
				func ():
				decideDrawPost()]

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

func decideDrawMin():
	var APCost = 0
	
	#Initial draw up to min amount of cards
	if hand.size() <= minHandSize:
		if enoughAP(APCost+1):
			APCost += 1
			movesList.append([possibleMoves.DRAW, abs(hand.size()-minHandSize)])
	
	await get_tree().process_frame
	advanceMoves.emit()

func decideMove():
	var averageRange
	var selfTile = map.getEntityTile(self)
	var APCost = 0
	
	averageRange = calculateAverageRange()
	
	#Caclulate the closest target
	var minDistance = 0
	var closestTarget
	for target in map.getEntities():
		if(target != self):
			if(target.team != team):
				
				var pathTo = characterPassableMap.get_id_path(selfTile, map.getEntityTile(target))
				
				if(minDistance >= pathTo.size() or closestTarget == null):
					minDistance = pathTo.size()
					closestTarget = target
	
	
	#Calculate the closest point on a ring of the average range to the target
	var targetRing = map.getTileRing(map.getEntityTile(closestTarget), averageRange)
	
	#Quick check that it's not already in a good position
	if !targetRing.has(selfTile):
		var closestPath = null
		minDistance = 0
		
		for pos in targetRing:
			if(closestTarget.canSeeTile(pos) and map.getEntityTile(pos) == null):
				var pathTo = AStarGrid.get_id_path(selfTile, pos)
				
				if(minDistance >= pathTo.size() or closestPath == null):
					if(AStarGrid.is_in_boundsv(pos)):
							minDistance = pathTo.size()
							closestPath = pathTo
		
		
		
		while !enoughAP(closestPath.size()-1):
			closestPath.resize(closestPath.size()-1)
		
		movesList.append([possibleMoves.MOVE, closestPath[closestPath.size()-1]])
		
		await get_tree().process_frame
		advanceMoves.emit()

func decideUseCards():
	var APCost = 0
	var selfTile = map.getEntityTile(self)
	var attackingCards = []
	
	for card in hand:
		if card.AITags.has("Damage"):
			attackingCards.append(card)
	
	#For each card, find all the good targets 
	for card in attackingCards:
		if(enoughAP(APCost + card.cost)):
			var tileCircle = map.getTileCircle(selfTile, card.range)
			var targetsInRange = []
			
			for tile in tileCircle:
				var tileEntity = map.getTileEntity(tile)
				
				#I did it nested as to first, make sure it doesn't crash without an entity,
				#Second, to conserve resources from canTargetTile
				#Third, your mother
				if(tileEntity != null):
					if(tileEntity.team != team):
						if(canTargetTile(tile, card.validTargets)):
							targetsInRange.append(tile)
			
			if(targetsInRange != []):
				if([true, false].pick_random()):
					APCost += card.cost
					movesList.append([possibleMoves.CARD, targetsInRange.pick_random(), card])
	
	await get_tree().process_frame
	advanceMoves.emit()

func decideDrawPost():
	if hand.size() <= averageHandSize:
		movesList.append([possibleMoves.DRAW, abs(hand.size()-averageHandSize)])
	
	await get_tree().process_frame
	advanceMoves.emit()

func calculateAverageRange(cards = hand) -> int:
	var averageRange = 0

	for card in cards:
		averageRange += card.range
	
	averageRange /= cards.size()
	return averageRange
