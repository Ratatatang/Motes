extends Node

const INT_MAX := 9223372036854775807
const INT_MIN := -9223372036854775808

var currentLevelMap : LevelMap

var SFXVolume = 1.0

var peer
var playerIDs = {}
var customGamemode
var singleplayer = true

class customGameInfo:
	var gamemode
	var playerTeams
	
	func _init(newGamemode, newPlayerTeams):
		gamemode = newGamemode
		playerTeams = newPlayerTeams
