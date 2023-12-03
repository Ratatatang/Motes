extends Node2D

@onready var player = "res://Scripts+Scenes/Board/Tiles/PlayerData/Player.tscn"
@onready var gamePieces = $TileMap/GamePieces
@onready var tilemap = $TileMap
@onready var line = $TileMap/Line2D

var curDeck
var maxHandSize
var hand
var maxAP
var curAP
var maxHP
var curHP

var controlledCharacters = []
var selectedCharacter


func _ready():
	randomize()
	loadNewPlayer(player)
	selectedCharacter = controlledCharacters[0]
	getCharacterData(selectedCharacter)
	line.position = selectedCharacter.position
	$UI.dealHand()
	updateDeckAmountLabel()

func getCharacterData(cha) -> void:
	curDeck = cha.curDeck
	maxHandSize = cha.maxHandSize
	maxAP = cha.maxAP
	curAP = cha.curAP
	maxHP = cha.maxHP
	curHP = cha.curHP
	curDeck.shuffle()

func drawCard() -> String:
	var card = curDeck.pop_front()
	updateDeckAmountLabel()
	return card

func enoughAP(num : int) -> bool:
	return selectedCharacter.enoughAP(num)

func incrementAP(num : int) -> void:
	selectedCharacter.incrementAP(num)
	curAP = selectedCharacter.curAP

func updateAPLabel() -> void:
	$UI/Buttons/APLabel.text = str(curAP) + "/" + str(maxAP)

func updateDeckAmountLabel() -> void:
	$UI/CardBack/CardsLeft.text = "Cards Left: "+str(curDeck.size())

func useCard(card : NodePath) -> void:
	pass
	
func loadNewPlayer(loadPath : String) -> void:
	var newCharacter = load(loadPath).instantiate()
	newCharacter.tilemap = $TileMap
	gamePieces.add_child(newCharacter)
	controlledCharacters.append(newCharacter)
