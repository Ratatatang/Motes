extends Node

const INT_MAX := 9223372036854775807
const INT_MIN := -9223372036854775808

var currentLevelMap : LevelMap

var SFXVolume = 1.0

var peer
var playerIDs = {}
var customGamemode
var singleplayer = true

var cardsRefrence

func _ready():
	randomize()
	var text = FileAccess.open("res://Scripts/Cards/CardData/CardDirectory.json", FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(text.get_as_text())

	if parse_result != OK:
		print("Error %s reading cards directory." % parse_result)
		return

	cardsRefrence = json.get_data()

class customGameInfo:
	var gamemode
	var playerTeams
	
	func _init(newGamemode, newPlayerTeams):
		gamemode = newGamemode
		playerTeams = newPlayerTeams

func unpackageCard(package):
	var card = load(cardsRefrence.get(package.get("name"))).new()
	return card
