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

var areaRotation = 0

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

@rpc("any_peer", "call_local")
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
	updateAStar.rpc()
	currentTurn = 0
	
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

@rpc("any_peer")
func selectedMoveTo(tilePos):
	if(selectedCharacter.isPassablePoint(tilePos)):
		if(enoughAP((selectedCharacter.getPath(tilePos).size()-1)*2)):
			disableLine()
			%UI.disableMove()
			%UI.disableCards()
			%UI.enableUI()
				
			%Combat.setAction(1)
			
			await(moveTo(tilePos, selectedCharacter))
				
			%UI.enableMove()
			%UI.enableCards()
		else:
			selectedCharacter.invalidMovement()
	else:
		selectedCharacter.invalidMovement()

func AIMoveTo(tilePos):
	if(selectedCharacter.isPassablePoint(tilePos)):
		if(enoughAP(selectedCharacter.getPath(tilePos).size()-1)):
			moveTo(tilePos, selectedCharacter)

func moveTo(tilePos, entity):
	decrementAP(entity.getPath(tilePos).size()-1)
	%Environment.removeHighlight(entity)
	entity.setPath(tilePos)

	await(entity.finishedMoving)
	
	updateAStar.rpc()
	%Environment.highlightEntity(entity)

func remoteMoveOnPath(path, entityPos):
	pass

func selectedUseCard(tilePos):
	if(%Environment.getTileCircle(%Environment.getEntityTile(selectedCharacter), selectedCard.getRange()).has(tilePos)):
		if(selectedCharacter.canTargetTile(tilePos, selectedCard.getValidTargets())):
			if(enoughAP(selectedCard.getCost())):
				decrementAP(selectedCard.getCost())
				%UI.updateLabels()
				
				useCard(tilePos, selectedCharacter, selectedCard.cardData)
				
				%Combat.setAction(1)
				%UI.enableUI()
				
				getHand().erase(selectedCard.cardData)
				selectedCard.freeSelf()
				
				updateAStar.rpc()
				clearTargetedTiles()

func AIUseCard(tilePos, card, entity = selectedCharacter):
	if(%Environment.getTileCircle(%Environment.getEntityTile(entity), card.range).has(tilePos)):
		if(entity.canTargetTile(tilePos, card.validTargets)):
			if(enoughAP(card.cost)):
				decrementAP(card.cost)
				
				%AnimationCard.passData(card)
				%ScreenAnimations.play("useCard")
				
				useCard(tilePos, selectedCharacter, selectedCard)
				
				getHand().erase(card)

func useCard(tilePos, entity, card):
	for target in card.targeting:
		target.call(tilePos, %Environment.getTileEntity(tilePos), entity, areaRotation)

func cancelMove():
	disableLine()
	%UI.enableUI() 
	%Combat.setAction(1)
	selectedCard = null

func cancelCard():
	%UI.enableUI()
	%Combat.setAction(1)
	clearTargetedTiles()

func cancelInspect():
	%ScreenAnimations.play("cancelInspect")
	await %ScreenAnimations.animation_finished
	%UI.enableUI()
	%Combat.setAction(1)

func cancelStatus():
	%ScreenAnimations.play("cancelStatus")
	await %ScreenAnimations.animation_finished
	%UI.enableUI()
	%Combat.setAction(1)

@rpc("any_peer")
func loadCharacter(entity):
	if MasterInfo.singleplayer:
		loadCharacterSingleplayer(entity)
	else:
		selectedCharacter = entity
		%Environment.highlightEntity(selectedCharacter)
		moveCameraToTile(%Environment.getEntityTile(entity))
	
		updateAStar.rpc()
			
		%UI.enableUI()
		%UI.loadHand(selectedCharacter)
		%UI.updateLabels()


func loadCharacterSingleplayer(entity):
	selectedCharacter = entity
	%Environment.highlightEntity(selectedCharacter)
	moveCameraToTile(%Environment.getEntityTile(entity))
	
	updateAStar.rpc()
	
	if(!entity.isAI):
		%UI.enableUI()
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
	var emptyTiles = []
	var tiles = %Environment.getTileCircle(%Environment.getEntityTile(entity), card.getRange())
	
	for tile in tiles:
		if(entity.canSeeTile(tile)):
			if(entity.canTargetTile(tile, selectedCard.getValidTargets())):
				validTiles.append(tile)
			else:
				if AStarGrid.is_in_boundsv(tile):
					emptyTiles.append(tile)
			targetedTiles.append(tile)
	
	%Environment.targetTiles(validTiles, emptyTiles)

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
		var areaTiles = selectedCard.getAreaOfEffect()
		
		if(selectedCard.getAOERotations()):
			if(areaRotation > areaTiles.size()-1):
				areaRotation = 0
			areaTiles = areaTiles[areaRotation]
		else:
			areaRotation = 0
		
		for tile in areaTiles:
				
			var tileIteration = mouseTile + tile
			
			if(AStarGrid.is_in_boundsv(tileIteration)):
				if(!%Environment.isTileSolid(tileIteration)):
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

func rotateAOE():
	areaRotation += 1

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

func openStatus():
	%StatusList.loadStatusIcons(selectedCharacter.statusEffects)
	%ScreenAnimations.play("inspectStatus")

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
