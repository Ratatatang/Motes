extends Node

signal AIAdvance 


var AStarGrid : AStarGrid2D
var AStarGridAI : AStarGrid2D
var AStarGridAIPassable : AStarGrid2D

var selectedCharacter
var selectedCard

var cardsRefrence

var targetedTiles = []
var mouseTargets = []

var entityTurnOrder = []
var currentTurn = 0

func _ready():
	AStarGrid = AStarGrid2D.new() 
	AStarGrid.cell_size = Vector2(64, 64)
	AStarGrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	AStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStarGrid.update()
	
	AStarGridAI = AStarGrid2D.new() 
	AStarGridAI.cell_size = Vector2(64, 64)
	AStarGridAI.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	AStarGridAI.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStarGridAI.update()
	
	AStarGridAIPassable = AStarGrid2D.new() 
	AStarGridAIPassable.cell_size = Vector2(64, 64)
	AStarGridAIPassable.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	AStarGridAIPassable.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStarGridAIPassable.update()
	
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
	
	AStarGridAI.clear()
	AStarGridAI.region = %Environment.get_used_rect()
	AStarGridAI.update()
	
	AStarGridAIPassable.clear()
	AStarGridAIPassable.region = %Environment.get_used_rect()
	AStarGridAIPassable.update()
	
	for x in %Environment.get_used_rect().size.x:
		for y in %Environment.get_used_rect().size.y:
			
			var tilePos = Vector2i(x, y)
			
			var tileData = %Environment.get_cell_tile_data(0, tilePos)
			
			if tileData == null or tileData.get_custom_data("impassable") == true:
				AStarGrid.set_point_solid(tilePos)
				AStarGridAI.set_point_solid(tilePos)
				AStarGridAIPassable.set_point_solid(tilePos)
			else:
				AStarGrid.set_point_solid(tilePos, false)
				AStarGridAI.set_point_solid(tilePos, false)
				AStarGridAIPassable.set_point_solid(tilePos)
			
			if %Environment.getTileEntity(tilePos) != null:
				AStarGrid.set_point_solid(tilePos)
				AStarGridAI.set_point_solid(tilePos)
			
			if %Environment.getTileData(tilePos) != null:
				var tileBias = 0
				
				for effect in %Environment.getTileData(tilePos):
					tileBias += effect.bias
					
				AStarGridAI.set_point_weight_scale(tilePos, tileBias)
				AStarGridAIPassable.set_point_weight_scale(tilePos, tileBias)

func beginGame():
	updateAStar()
	
	%Camera.moveTo(%Environment.getEntityTile(entityTurnOrder[0])*64)
	loadCharacter(entityTurnOrder[0])
	currentTurn = 0

func advanceTurn():
	selectedCharacter.checkTurnEndEffects()
	
	if(currentTurn < entityTurnOrder.size()-1):
		currentTurn += 1
		unloadCharacter()
		loadCharacter(entityTurnOrder[currentTurn])
		selectedCharacter.checkTurnStartEffects()
	else:
		advanceRound()

func advanceRound():
	for character in entityTurnOrder:
		character.refreshAP()
		character.checkRoundEffects()

	unloadCharacter()
	loadCharacter(entityTurnOrder[0])
	selectedCharacter.checkTurnStartEffects()
	currentTurn = 0

func selectedMoveTo(tilePos):
	if(selectedCharacter.isPassablePoint(tilePos)):
		if(enoughAP(selectedCharacter.getPath(tilePos).size()-1)):
			
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
		else:
			selectedCharacter.invalidMovement()
	else:
		selectedCharacter.invalidMovement()

func AIMoveTo(tilePos):
	if(selectedCharacter.isPassablePoint(tilePos)):
		if(enoughAP(selectedCharacter.getPath(tilePos).size()-1)):
			
			decrementAP(selectedCharacter.getPath(tilePos).size()-1)
			%Environment.removeHighlight(selectedCharacter)
			selectedCharacter.setPath(tilePos)
			
			await(selectedCharacter.finishedMoving)
			
			%Environment.highlightEntity(selectedCharacter)

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

func AIUseCard(tilePos, card, entity = selectedCharacter):
	if(%Environment.getTileCircle(%Environment.getEntityTile(entity), card.range).has(tilePos)):
		if(entity.canTargetTile(tilePos, card.validTargets)):
			if(enoughAP(card.cost)):
				decrementAP(card.cost)
				
				%AnimationCard.passData(card)
				%ScreenAnimations.play("useCard")
				
				for target in card.targeting:
					target.call(tilePos, %Environment.getTileEntity(tilePos), entity)
				
				getHand().erase(card)

func cancelMove():
	disableLine()
	%UI.visible = true 
	%Combat.setAction(1)
	selectedCard = null

func cancelCard():
	%UI.visible = true
	%Combat.setAction(1)
	clearTargetedTiles()

func cancelInspect():
	%ScreenAnimations.play("cancelInspect")
	await %ScreenAnimations.animation_finished
	%UI.visible = true
	%Combat.setAction(1)

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
		executeAI()

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
				SFXHandler.playSFX(load("res://Assets/Cards/SFX/CardFlip.wav"), self)
				decrementAP(1)
				%UI.drawCard(getHand().back())
	
	if(getCurDeck().size() == 0):
		%UI.enableShuffle()

func AIDrawCard(num):
	for i in num:
		if(getCurDeck().size() > 0):
			if(getHand().size() < getMaxHandSize()):
				if(enoughAP(1)):
					selectedCharacter.drawCard()
					decrementAP(1)

func shuffleDeck():
	var newDeck = getDeck().duplicate()
	
	for card in getHand():
		newDeck.erase(card.name)
	
	newDeck.shuffle()
	selectedCharacter.curDeck = newDeck

func drawValidTargets(card = selectedCard, entity = selectedCharacter):
	var validTiles = []
	var tiles = %Environment.getTileCircle(%Environment.getEntityTile(entity), card.getRange())
	
	for tile in tiles:
		if(entity.canTargetTile(tile, selectedCard.getValidTargets())):
			validTiles.append(tile)
			targetedTiles.append(tile)
	
	%Environment.targetTiles(validTiles)

func clearTargetedTiles():
	clearMouseTargets()
	for tile in targetedTiles:
		%Environment.erase_cell(1, tile)
		
	targetedTiles.clear()
	%Environment.highlightEntity(selectedCharacter)

func checkMouseTargets(mouseTile):
	var targetTiles = []
	
	clearMouseTargets()
	if targetedTiles.has(mouseTile):
		for tile in selectedCard.getAreaOfEffect():
			var tileIteration = mouseTile + tile
			if(AStarGrid.is_in_boundsv(tileIteration)):
				targetTiles.append(tileIteration)
		
		mouseTargetTiles(targetTiles)

func mouseTargetTiles(tiles):
	mouseTargets = []
	for tile in tiles:
		if(AStarGrid.is_in_boundsv(tile)):
			mouseTargets.append(tile)
	
	if(mouseTargets != []):
		%Environment.set_cells_terrain_connect(1, mouseTargets, 0, 1, true)
	else:
		drawValidTargets()
			

func clearMouseTargets():
	for tile in mouseTargets:
		%Environment.erase_cell(1, tile)
	
	drawValidTargets()
			
func moveCameraToTile(tile):
	%Camera.tweenTo(Vector2(tile)*64)

func executeAI():
	for step in selectedCharacter.AISteps:
		step.call()
		await selectedCharacter.advanceMoves
		executeAIMoves()
		await AIAdvance
	
	advanceTurn()

func executeAIMoves():
	for move in selectedCharacter.movesList:
		#0: Move, 1: Draw, 2: Card 
		match move[0]:
			0:
				AIMoveTo(move[1])
				await selectedCharacter.finishedMoving
			1:
				AIDrawCard(move[1])
			2:
				AIUseCard(move[1], move[2])
				await %ScreenAnimations.animation_finished
	
	selectedCharacter.movesList = []
	await get_tree().process_frame
	AIAdvance.emit()

func inspectCard(card):
	%AnimationCard.passData(card)
	%ScreenAnimations.play("inspectCard")

func getAStar():
	return AStarGrid

func getAStarAI():
	return AStarGridAI

func getAStarGridAIPassable():
	return AStarGridAIPassable

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

func heal(num : int):
	selectedCharacter.heal(num)
