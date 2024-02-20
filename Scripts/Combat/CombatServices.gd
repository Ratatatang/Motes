extends Node

var AStarGrid : AStarGrid2D
var AStarGridCharactersPassable : AStarGrid2D

var selectedCharacter
var selectedCard

var cardsRefrence

var targetedTiles = []

var entityTurnOrder = []
var currentTurn = 0

func _ready():
	AStarGrid = AStarGrid2D.new() 
	AStarGrid.cell_size = Vector2(64, 64)
	AStarGrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	AStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStarGrid.update()
	
	AStarGridCharactersPassable = AStarGrid2D.new() 
	AStarGridCharactersPassable.cell_size = Vector2(64, 64)
	AStarGridCharactersPassable.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	AStarGridCharactersPassable.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStarGridCharactersPassable.update()
	
	randomize()
	var text = FileAccess.open("res://Scripts/Cards/CardData/CardDirectory.json", FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(text.get_as_text())

	if parse_result != OK:
		print("Error %s reading cards directory." % parse_result)
		return

	cardsRefrence = json.get_data()

func updateAStar():
	AStarGrid.clear()
	AStarGrid.region = %Environment.get_used_rect()
	AStarGrid.update()
	
	AStarGridCharactersPassable.clear()
	AStarGridCharactersPassable.region = %Environment.get_used_rect()
	AStarGridCharactersPassable.update()
	
	for x in %Environment.get_used_rect().size.x:
		for y in %Environment.get_used_rect().size.y:
			
			var tilePos = Vector2i(x, y)
			
			var tileData = %Environment.get_cell_tile_data(0, tilePos)
			
			if tileData == null or tileData.get_custom_data("impassable") == true:
				AStarGrid.set_point_solid(tilePos)
				AStarGridCharactersPassable.set_point_solid(tilePos)
			else:
				AStarGrid.set_point_solid(tilePos, false)
				AStarGridCharactersPassable.set_point_solid(tilePos, false)
			
			if %Environment.getTileEntity(tilePos) != null:
				AStarGrid.set_point_solid(tilePos)

func beginGame():
	updateAStar()
	
	%Camera.moveTo(%Environment.getEntityTile(entityTurnOrder[0])*64)
	loadCharacter(entityTurnOrder[0])
	currentTurn = 0

func advanceTurn():
	if(currentTurn < entityTurnOrder.size()-1):
		currentTurn += 1
		loadCharacter(entityTurnOrder[currentTurn])
	else:
		advanceRound()

func advanceRound():
	for character in entityTurnOrder:
		character.refreshAP()
	
	loadCharacter(entityTurnOrder[0])
	currentTurn = 0

func selectedMoveTo(tilePos):
	if(selectedCharacter.isPassablePoint(tilePos)):
		if(enoughAP(selectedCharacter.getPath(tilePos).size())):
			
			decrementAP(selectedCharacter.getPath(tilePos).size()-1)
			
			disableLine()
			%Environment.removeHighlight(selectedCharacter)
			
			selectedCharacter.setPath(tilePos)
			
			%UI.disableMove()
			%UI.disableCards()
			%UI.visible = true
			
			%Combat.setAction(1)
		
			await(selectedCharacter.finishedMoving)
			
			updateAStar()
			
			%Environment.highlightEntity(selectedCharacter)
			
			%UI.enableMove()
			%UI.enableCards()

func useCard(tilePos, entity = selectedCharacter, card = selectedCard):
	if(%Environment.getTileCircle(%Environment.getEntityTile(entity), card.getRange()).has(tilePos)):
		if(entity.canTargetTile(tilePos, card.getValidTargets())):
			if(enoughAP(card.getCost())):
				decrementAP(card.getCost())
				%UI.updateLabels()
				
				for target in card.getTargeting():
					target.call(tilePos, %Environment.getTileEntity(tilePos), entity)
				
				%Combat.setAction(1)
				%UI.visible = true
				
				getHand().erase(card.cardData)
				card.freeSelf()
				
				updateAStar()
				clearTargetedTiles()

func cancelMove():
	disableLine()
	%UI.visible = true
	%Combat.setAction(1)
	selectedCard = null

func cancelCard():
	%UI.visible = true
	%Combat.setAction(1)
	clearTargetedTiles()

func loadCharacter(entity):
	selectedCharacter = entity
	%Environment.highlightEntity(selectedCharacter)
	moveCameraToTile(%Environment.getEntityTile(entity))
	
	updateAStar()
	
	if(entity.team == "Player"):
		%UI.visible = true
		%UI.loadHand(selectedCharacter)
		%UI.updateLabels()
	else:
		selectedCharacter.decideMoves()

func unloadCharacter():
	if(selectedCharacter != null):
		%Environment.removeHighlight(selectedCharacter)
	selectedCharacter = null
	%UI.visible = false

func loadCard(card):
	selectedCard = card

func enableLine():
	selectedCharacter.enableLine()

func disableLine():
	selectedCharacter.disableLine()

func drawCard():
	if(getCurDeck().size() > 0):
		if(getHand().size() < getMaxHandSize()):
			if(enoughAP(1)):
				selectedCharacter.drawCard()
				decrementAP(1)
				%UI.drawCard(getHand().back())
	
	if(getCurDeck().size() == 0):
		%UI.enableShuffle()

func shuffleDeck():
	var newDeck = getDeck().duplicate()
	
	for card in getHand():
		newDeck.erase(card.name)
	
	newDeck.shuffle()
	selectedCharacter.curDeck = newDeck

func drawValidTargets(card = null, entity = selectedCharacter):
	var validTiles = []
	var tiles = %Environment.getTileCircle(%Environment.getEntityTile(entity), card.getRange())
	
	for tile in tiles:
		if(entity.canTargetTile(tile, selectedCard.getValidTargets())):
			validTiles.append(tile)
			targetedTiles.append(tile)
	
	%Environment.targetTiles(validTiles)

func clearTargetedTiles():
	for tile in targetedTiles:
		%Environment.erase_cell(1, tile)
		
	targetedTiles.clear()
	%Environment.highlightEntity(selectedCharacter)

func moveCameraToTile(tile):
	%Camera.tweenTo(Vector2(tile)*64)

func getAStar():
	return AStarGrid

func getAStarCharactersPassable():
	return AStarGridCharactersPassable

func getCardsRefrence():
	return cardsRefrence


func getDeck():
	return selectedCharacter.deck

func getCurDeck():
	return selectedCharacter.curDeck

func getHand():
	return selectedCharacter.hand

func getMaxHandSize():
	return selectedCharacter.maxHandSize

func getMaxAP():
	return selectedCharacter.maxAP

func getCurAP():
	return selectedCharacter.curAP

func getMaxHP():
	return selectedCharacter.maxHP

func getCurHP():
	return selectedCharacter.curHP


func enoughAP(num : int):
	return selectedCharacter.enoughAP(num)

func incrementAP(num : int):
	selectedCharacter.incrementAP(num)
	%UI.updateAPLabel()

func decrementAP(num : int):
	selectedCharacter.decrementAP(num)
	%UI.updateAPLabel()

func damage(num : int, type = null):
	selectedCharacter.damage(num, type)
