extends Node2D

@onready var tileMarker = "res://Scripts+Scenes/Board/Tiles/tile_marker.tscn"
@onready var gamePieces = $TileMap/GamePieces
@onready var tilemap = $TileMap
@onready var UI = $UI
@onready var movementMarker = $MovementCostMarker

var characters = []
var selectedCharacter
var doubleSelected = false
var cardSelected = null

var curPath

var markers = []

func _ready():
	randomize()
	loadNewEnitity("res://Scripts+Scenes/Board/Tiles/Entities/PlayerData/Player.tscn")
	loadNewEnitity("res://Scripts+Scenes/Board/Tiles/Entities/EnemyData/Enemy.tscn", Vector2(32, 96))
	selectedCharacter = characters[0]
	getCurDeck().shuffle()
	
	UI.dealHand()
	updateDeckAmountLabel()
	
	SignalManager.connect("selectedCard", Callable(self, "selectCard"))

func _physics_process(delta):
	movementMarker.global_position = Vector2(get_global_mouse_position().x, get_global_mouse_position().y+25)

func _input(event):
	if(event.is_action_pressed("space")):
		undouble()
	
	if(event.is_action_pressed("leftClick")):
		if(tilemap.local_to_map(get_global_mouse_position()) == tilemap.local_to_map(selectedCharacter.global_position) and cardSelected == null):
			if(doubleSelected == false):
				doubleSelect()
			else:
				undouble()
		elif(doubleSelected == true):
			if(enoughAP(selectedCharacter.getMovementPoints().size()-1)):
				selectedCharacter.setPath()
				decrementAP(selectedCharacter.getMovementPoints().size()-1)
				undouble()
		elif(cardSelected != null and selectedCharacter.viableTarget):
			undouble()
			selectedCharacter.disableArc()
			var targets = selectedCharacter.getArcTargets()
			
			for target in targets.keys():
				var trueTarget = targets.get(target)
				if(target == "Tiles"):
					cardSelected.cardData._OnTileEffect(trueTarget)
				elif(target == "Enemies"):
					cardSelected.cardData._OnEnemyEffect(trueTarget)
			
			cardSelected.freeSelf()
			cardSelected = null
	
	if(event.is_action_pressed("rightClick")):
		undouble()
		if(cardSelected != null):
			cardSelected.disabled = false
			cardSelected.unselect()
			cardSelected = null
			selectedCharacter.disableArc()
	
func doubleSelect():
	selectedCharacter.enableLine()
	doubleSelected = true
	movementMarker.visible = true
	UI.setDown()
	UI.raiseDisabled = true
	
func undouble():
	selectedCharacter.disableLine()
	doubleSelected = false
	movementMarker.visible = false
	UI.raiseDisabled = false

func drawCard() -> String:
	var card = getCurDeck().pop_front()
	updateDeckAmountLabel()
	return card

func selectCard(card):
	if(selectedCharacter.enoughAP(card.cardData.cost)):
		decrementAP(card.cardData.cost)
		print("used card "+card.cardData.name)
		UI.setDown()
		UI.raiseDisabled = true
		card.disabled = true
		cardSelected = card
		selectedCharacter.arcTargeting = card.cardData.targeting
		selectedCharacter.enableArc()

func enoughAP(num : int) -> bool:
	return selectedCharacter.enoughAP(num)

func incrementAP(num : int) -> void:
	selectedCharacter.incrementAP(num)
	updateAPLabel()
	
func decrementAP(num : int) -> void:
	selectedCharacter.decrementAP(num)
	updateAPLabel()

func updateAPLabel() -> void:
	$UI/Buttons/APLabel.text = str(getCurAP()) + "/" + str(getMaxAP())

func updateDeckAmountLabel() -> void:
	$UI/CardBack/CardsLeft.text = "Cards Left: "+str(getCurDeck().size())

func advanceTurn():
	incrementAP(10)

func loadNewEnitity(loadPath : String, pos = Vector2(32, 32)) -> void:
	var newEnitity = load(loadPath).instantiate()
	newEnitity.tilemap = $TileMap
	newEnitity.global_position = pos
	newEnitity.otherEntities = characters
	characters.append(newEnitity)
	gamePieces.add_child(newEnitity)
	
	for character in characters:
		character.updateImpassable()

func getCurDeck():
	return selectedCharacter.curDeck

func getCurAP():
	return selectedCharacter.curAP

func getMaxAP():
	return selectedCharacter.maxAP

func getMaxHandSize():
	return selectedCharacter.maxHandSize

