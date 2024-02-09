extends Node

var AStarGrid : AStarGrid2D

var selectedCharacter : PlayerPawn


func _ready():
	#%Combat.setAction(0)
	AStarGrid = AStarGrid2D.new() 
	AStarGrid.region = %Environment.get_used_rect()
	AStarGrid.cell_size = Vector2(64, 64)
	AStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStarGrid.update()
	updateAStar()

func updateAStar():
	for x in %Environment.get_used_rect().size.x:
		for y in %Environment.get_used_rect().size.y:
			
			var tilePos = Vector2i(x, y)
			
			var tileData = %Environment.get_cell_tile_data(0, tilePos)
			
			if tileData == null or tileData.get_custom_data("impassable") == true:
				AStarGrid.set_point_solid(tilePos)
			else:
				AStarGrid.set_point_solid(tilePos, false)

func drawCard():
	return getCurDeck().pop_front()

func selectedMoveTo(tilePos):
	%Environment.removeHighlight(selectedCharacter)
	selectedCharacter.setPath(tilePos)
	await(selectedCharacter.finishedMoving)
	%Environment.highlightEntity(selectedCharacter)

func loadCharacter(entity):
	selectedCharacter = entity
	%Environment.highlightEntity(selectedCharacter)
	%UI.visible = true

func unloadCharacter():
	if(selectedCharacter != null):
		%Environment.removeHighlight(selectedCharacter)
	selectedCharacter = null
	%UI.visible = false

func getAStar():
	return AStarGrid
	

func getDeck():
	return selectedCharacter.deck

func getCurDeck():
	return selectedCharacter.curDeck

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

func decrementAP(num : int):
	selectedCharacter.decrementAP(num)

func damage(num : int):
	selectedCharacter.damage(num)
