extends Node2D

var deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "Fireball", "Fireball", "Fireball", "Fireball", "Fireball"]
var curDeck
var maxHandSize = 8
var maxAP
var curAP
var maxHP
var curHP

func ready():
	randomize()
	curDeck = deck.duplicate()
	curDeck.shuffle()

func drawCard():
	return deck.pop_front()

func setStaminaLabel(maxS, tempS):
	$UI/Buttons/Staminalabel.text = str(tempS) + "/" + str(maxS)

func useCard(card):
	pass

