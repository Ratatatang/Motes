extends FireColor

func _init():
	colorName = "Blue"

func _hurt(step):
	step[1].damage(step[2]*2, "Fire")

func _ignite(step):
	MasterInfo.currentLevelMap.setTileData(step[1], "res://Scenes/Combat/Board/Tiles/Effects/orangeFlame.tscn")
