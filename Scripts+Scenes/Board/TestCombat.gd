extends Node2D

@onready var tileMarker = "res://Scripts+Scenes/Board/Tiles/tile_marker.tscn"
@onready var gamePieces = $TileMap/GamePieces
@onready var tilemap = $TileMap
@onready var UI = $UI
@onready var movementMarker = $MovementCostMarker

var curDeck
var maxHandSize
var hand
var maxAP
var curAP
var maxHP
var curHP

var characters = []
var selectedCharacter
var doubleSelected = false

var curPath

var markers = []

func _ready():
	randomize()
	loadNewEnitity("res://Scripts+Scenes/Board/Tiles/Entities/PlayerData/Player.tscn")
	loadNewEnitity("res://Scripts+Scenes/Board/Tiles/Entities/EnemyData/Enemy.tscn", Vector2(32, 96))
	selectedCharacter = characters[0]
	getCharacterData(selectedCharacter)
	
	UI.dealHand()
	updateDeckAmountLabel()

func _physics_process(delta):
	movementMarker.global_position = Vector2(get_global_mouse_position().x, get_global_mouse_position().y+25)

func _input(event):
	if(event.is_action_pressed("space")):
		undouble()
	
	if(event.is_action_pressed("leftClick")):
		if(tilemap.local_to_map(get_global_mouse_position()) == tilemap.local_to_map(selectedCharacter.global_position)):
			if(doubleSelected == false):
				doubleSelect()
			else:
				undouble()
		elif(doubleSelected == true):
			selectedCharacter.setPath()
			undouble()
	
	if(event.is_action_pressed("rightClick")):
		if(doubleSelected == true):
			undouble()

func getCharacterData(cha) -> void:
	curDeck = cha.curDeck
	maxHandSize = cha.maxHandSize
	maxAP = cha.maxAP
	curAP = cha.curAP
	maxHP = cha.maxHP
	curHP = cha.curHP
	curDeck.shuffle()
	
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
	var card = curDeck.pop_front()
	updateDeckAmountLabel()
	return card

func cardUsed(card):
	print("click!")
#	var targetableTiles = []
#	for tile in tilemap.get_used_cells():
#		targetableTiles.append(tilemap.map_to_local(tile))
	
#	for tile in targetableTiles:
#		var marker = load(tileMarker).instantiate()
#		marker.global_position = tile.global_position

func enoughAP(num : int) -> bool:
	return selectedCharacter.enoughAP(num)

func incrementAP(num : int) -> void:
	selectedCharacter.incrementAP(num)
	curAP = selectedCharacter.curAP

func updateAPLabel() -> void:
	$UI/Buttons/APLabel.text = str(curAP) + "/" + str(maxAP)

func updateDeckAmountLabel() -> void:
	$UI/CardBack/CardsLeft.text = "Cards Left: "+str(curDeck.size())

func loadNewEnitity(loadPath : String, pos = Vector2(32, 32)) -> void:
	var newEnitity = load(loadPath).instantiate()
	newEnitity.tilemap = $TileMap
	newEnitity.global_position = pos
	newEnitity.otherEntities = characters
	characters.append(newEnitity)
	gamePieces.add_child(newEnitity)
	
	for character in characters:
		character.updateImpassable()
