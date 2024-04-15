extends Node

signal AIAdvance 


var AStarGrid : AStarGrid2D
var AStarGridAI : AStarGrid2D
var AStarGridAIPassable : AStarGrid2D

var selectedCharacter
var selectedCard

var targetedTiles = []
var mouseTargets = []

var entityTurnOrder = []
@export var currentTurn = 0

var areaRotation = 0

var cardsHistory = []

func _ready():
	currentTurn = 0
	
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
	if MasterInfo.singleplayer:
		loadCharacter()
		updateAStar()
	else:
		print(entityTurnOrder[0].parentID)
		loadCharacter.rpc_id(entityTurnOrder[0].parentID)

@rpc("any_peer", "call_local")
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
	
	currentTurn = 0
	unloadCharacter()
	loadCharacter(entityTurnOrder[0])
	selectedCharacter.checkTurnStartEffects()


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
			invalidMovement()
	else:
		invalidMovement()

@rpc("any_peer")
func remoteSelectedMoveTo(tilePos):
	var parentID = selectedCharacter.parentID
	
	if(selectedCharacter.isPassablePoint(tilePos)):
		if(enoughAP((selectedCharacter.getPath(tilePos).size()-1)*2)):
			
			disableLine.rpc_id(parentID)
			%UI.disableMove.rpc_id(parentID)
			%UI.disableCards.rpc_id(parentID)
			%UI.enableUI.rpc_id(parentID)
				
			%Combat.setAction.rpc_id(parentID, 1)
			
			await(remoteMoveTo(tilePos, selectedCharacter, parentID))
				
			%UI.enableMove.rpc_id(parentID)
			%UI.enableCards.rpc_id(parentID)
		else:
			invalidMovement.rpc_id(parentID)
	else:
		invalidMovement.rpc_id(parentID)

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

func remoteMoveTo(tilePos, entity, parentID):
	var AP = entity.getPath(tilePos).size()-1
	decrementAP.rpc_id(parentID, AP)
	%Environment.removeHighlightTile.rpc_id(parentID, %Environment.getEntityTile(entity))
	entity.setPath(tilePos)

	await(entity.finishedMoving)
	
	updateAStar.rpc()
	%Environment.highlightTile.rpc_id(parentID, %Environment.getEntityTile(entity))

func selectedUseCard(tilePos):
	if(%Environment.getTileCircle(%Environment.getEntityTile(selectedCharacter), selectedCard.getRange()).has(tilePos)):
		if(selectedCharacter.canTargetTile(tilePos, selectedCard.getValidTargets())):
			if(enoughAP(selectedCard.getCost())):
				decrementAP(selectedCard.getCost())
				
				useCard(tilePos, selectedCharacter, selectedCard.cardData)
				
				if !MasterInfo.singleplayer:
					%Combat.cardUsed(selectedCard.cardData.packageToDict())
				
				%Combat.setAction(1)
				%UI.enableUI()
				
				getHand().erase(selectedCard.cardData)
				selectedCard.freeSelf()
				
				updateAStar.rpc()
				clearTargetedTiles()

@rpc("any_peer")
func remoteSelectedUseCard(tilePos, cardData, rotation):
	var parentID = selectedCharacter.parentID
	var card = MasterInfo.unpackageCard(cardData)
	var cost = card.getCost()

	if(%Environment.getTileCircle(%Environment.getEntityTile(selectedCharacter), card.getRange()).has(tilePos)):
		if(selectedCharacter.canTargetTile(tilePos, card.getValidTargets())):
			if(enoughAP(cost)):
				decrementAP.rpc_id(parentID, cost)
				 
				useCard(tilePos, selectedCharacter, card, rotation)
				%Combat.cardUsed.rpc_id(parentID, cardData)
				
				%Combat.setAction.rpc_id(parentID, 1)
				%UI.enableUI.rpc_id(parentID)
				
				freeSelectedCard.rpc_id(parentID, cardData)
				
				updateAStar.rpc()
				clearTargetedTiles.rpc_id(parentID)

func AIUseCard(tilePos, card, entity = selectedCharacter):
	if(%Environment.getTileCircle(%Environment.getEntityTile(entity), card.range).has(tilePos)):
		if(entity.canTargetTile(tilePos, card.validTargets)):
			if(enoughAP(card.cost)):
				decrementAP(card.cost)
				
				%AnimationCard.passData(card)
				%ScreenAnimations.play("useCard")
				
				useCard(tilePos, selectedCharacter, selectedCard)
				
				getHand().erase(card)

func useCard(tilePos, entity, card, rotation = areaRotation):
	for target in card.targeting:
		target.call(tilePos, %Environment.getTileEntity(tilePos), entity, rotation)
	
	cardsHistory.append(card)

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

func cancelHistory():
	%ScreenAnimations.play("cancelHistory")
	await %ScreenAnimations.animation_finished
	%UI.enableUI()
	%Combat.setAction(1)

@rpc("any_peer", "call_local")
func loadCharacter(entity = entityTurnOrder[currentTurn]):
	if MasterInfo.singleplayer:
		loadCharacterSingleplayer(entity)
	else:
		selectedCharacter = entity
		
		if multiplayer.get_unique_id() == entity.parentID:
			%Environment.highlightEntity(selectedCharacter)
			moveCameraToTile(%Environment.getEntityTile(entity))
		
			updateAStar.rpc()
			
			%UI.enableUI()
			%UI.loadHand(selectedCharacter)
			%UI.updateLabels()
		else:
			loadCharacter.rpc_id(entity.parentID)


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

@rpc("any_peer")
func unloadCharacter():
	if MasterInfo.singleplayer:
		if selectedCharacter != null:
			%Environment.removeHighlight(selectedCharacter)
			%UI.visible = false
		
	elif(selectedCharacter != null):
		if selectedCharacter.parentID != multiplayer.get_unique_id():
			var parentID = selectedCharacter.parentID
			
			unloadCharacter.rpc_id(parentID)
			%Environment.removeHighlightTile.rpc_id(parentID, %Environment.getEntityTile(selectedCharacter))
		else:
			%UI.visible = false
			
			if multiplayer.get_unique_id() == 1:
				%Environment.removeHighlight(selectedCharacter)
		
	selectedCharacter = null

func loadCard(card):
	selectedCard = card

func enableLine():
	selectedCharacter.enableLine()

@rpc("any_peer")
func disableLine():
	selectedCharacter.disableLine()

@rpc("any_peer")
func invalidMovement():
	selectedCharacter.invalidMovement()

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
	
	if card == null:
		return
	
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

@rpc("any_peer")
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

func openCardsHistory():
	%CardsList.loadCardsHistory(cardsHistory)
	%ScreenAnimations.play("openHistory")

@rpc("any_peer")
func freeSelectedCard(cardData):
	selectedCard.freeSelf()
	getPackagedHand().erase(cardData)

func getAStar():
	return AStarGrid

func getAStarAI():
	return AStarGridAI

func getAStarGridAIPassable():
	return AStarGridAIPassable


func getDeck():
	return selectedCharacter.deck

func getCurDeck():
	return selectedCharacter.curDeck

func getHand():
	return selectedCharacter.hand

func getPackagedHand():
	return selectedCharacter.packagedHand

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

@rpc("any_peer")
func decrementAP(num : int):
	selectedCharacter.decrementAP(num)
	%UI.updateAPLabel()

func damage(num : int, type = null):
	selectedCharacter.damage(num, type)

func heal(num : int):
	selectedCharacter.heal(num)
