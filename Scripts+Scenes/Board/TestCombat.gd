extends Node2D

@onready var player = load("res://Scripts+Scenes/Board/Tiles/PlayerData/Player.tscn")

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
	var newPlayer = player.instantiate()
	add_child(newPlayer)
	controlledCharacters.append(newPlayer)
	selectedCharacter = controlledCharacters[0]
	getCharacter(selectedCharacter)
	$UI.dealHand()
	updateDeckAmountLabel()

func getCharacter(cha) -> void:
	curDeck = cha.getCurDeck()
	maxHandSize = cha.getMaxHandSize()
	maxAP = cha.getMaxAP()
	curAP = cha.getCurAP()
	maxHP = cha.getMaxHP()
	curHP = cha.getCurHP()
	curDeck.shuffle()

func drawCard() -> String:
	var card = curDeck.pop_front()
	updateDeckAmountLabel()
	return card

func enoughAP(num : int) -> bool:
	return selectedCharacter.enoughAP(num)

func incrementAP(num : int) -> void:
	selectedCharacter.incrementAP(num)
	curAP = selectedCharacter.getCurAP()

func updateAPLabel() -> void:
	$UI/Buttons/APLabel.text = str(curAP) + "/" + str(maxAP)

func updateDeckAmountLabel() -> void:
	$UI/CardBack/CardsLeft.text = "Cards Left: "+str(curDeck.size())

func useCard(card : NodePath) -> void:
	pass
