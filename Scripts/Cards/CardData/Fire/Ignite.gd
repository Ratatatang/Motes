extends FireCard

func _init():
	super()
	displayName = "Ignite"
	name = "Ignite"
	description = "Lights a tile on fire or the enemy on the tile for 3 turns."
	castChance = 100
	cost = 5
	targeting = ["Enemies", "Tiles"]

func _OnTileEffect(target):
	MasterInfo.currentLevelMap.setTileData(target, {"burning" = 3})
	
func _OnEnemyEffect(target: Entity):
	pass
