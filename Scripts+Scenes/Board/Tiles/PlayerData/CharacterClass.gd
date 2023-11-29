extends CharacterBody2D
class_name CharacterClass

var deck = ["Ignite", "Ignite", "Ignite", "Ignite", "Ignite", "Fireball", "Fireball", "Fireball", "Fireball", "Fireball"]
var curDeck = deck.duplicate()
var maxHandSize = 8
var hand = {}
var maxAP = 30
var curAP = 30
var maxHP = 20
var curHP = 20

func getCurDeck() -> Array:
	return curDeck

func getMaxHandSize() -> int:
	return maxHandSize

func getMaxAP() -> int:
	return maxAP

func getCurAP() -> int:
	return curAP

func getMaxHP() -> int:
	return maxHP
	
func getCurHP() -> int:
	return maxAP

func setMaxHandSize(new_size : int) -> void:
	maxHandSize = new_size

func setMaxAP(new_AP : int) -> void:
	maxAP = new_AP

func setMaxHP(new_HP : int) -> void:
	maxHP = new_HP
	
func setCurHP(new_HP : int) -> void:
	curHP = new_HP

func setCurAP(new_AP : int) -> void:
	curAP = new_AP

func incrementAP(num : int) -> void:
	curAP += num
	
func enoughAP(cost : int) -> bool:
	if(cost <= curAP):
		return true
	else:
		return false
