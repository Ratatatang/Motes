class_name FireColor

var colorName
var colorHex

func instructionFilter(steps : Array):
	for step in steps:
		match step[0]:
			"Hurt":
				#Step[1]: Entity, Step[2]: Amount
				_hurt(step)
			"Heal":
				#Step[1]: Entity, Step[2]: Amount
				_heal(step)
			"Ignite":
				#Step[1]: Tile
				_ignite(step)

func _hurt(step):
	step[1].damage(step[2], "Fire")

func _heal(step):
	step[1].heal(step[2])

func _ignite(step):
	MasterInfo.currentLevelMap.setTileData(step[1], "res://Scenes/Combat/Board/Tiles/Effects/orangeFlame.tscn")
