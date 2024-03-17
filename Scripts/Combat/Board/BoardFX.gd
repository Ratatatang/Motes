extends TileMap
class_name LevelMap

var grid = {} # for the 2d grid
var dataGrid
var entityGrid

var entities = []

var mouseHighlights = []

var teamSpawnPoints = {
	0: [Vector2(1, 9), Vector2(1, 8), Vector2(1, 10), Vector2(2, 9), Vector2(2, 8), Vector2(2, 10)],
	1: [Vector2(32, 11), Vector2(32, 12), Vector2(32, 10), Vector2(33, 11), Vector2(33, 12), Vector2(33, 10)],
	2: [Vector2(18, 2), Vector2(17, 2), Vector2(19, 2), Vector2(18, 1), Vector2(17, 1), Vector2(19, 1)],
	3: [Vector2(13, 18), Vector2(12, 18), Vector2(14, 18), Vector2(13, 19), Vector2(12, 19), Vector2(14, 19)],
	4: [Vector2(18, 9), Vector2(18, 10), Vector2(18, 8), Vector2(19, 9), Vector2(17, 9), Vector2(19, 10),]
}

func _ready():
	MasterInfo.currentLevelMap = self
	
	var dimensions = get_used_cells(0)
	
	for cell in dimensions:
		grid[cell] = null
	
	dataGrid = grid.duplicate(true)
	entityGrid = grid.duplicate(true)

@rpc("any_peer")
func addEntity(entity, gridPos, team = "Player"):
	var newEntity = load(entity).instantiate()
	
	newEntity.AStarGrid = %Services.getAStar()
	newEntity.characterPassableMap = %Services.getAStarGridAIPassable()
	newEntity.AStarGridAI = %Services.getAStarAI()
	newEntity.cardsRef = %Services.getCardsRefrence()
	newEntity.map = self
	newEntity.setTeam(team)
	newEntity.global_position = gridPos*64
	
	entityGrid[Vector2i(gridPos)] = newEntity
	entities.append(newEntity)
	
	newEntity.drawCard()
	newEntity.drawCard()
	newEntity.drawCard()
	newEntity.drawCard()
	
	%GamePieces.add_child(newEntity)
	
	%Services.entityTurnOrder.append(newEntity)

func getRandomStartPoint(team):
	return teamSpawnPoints.get(team).pick_random()

func highlightEntity(entity):
	set_cell(1, getEntityTile(entity), 2, Vector2i(0, 3))

func removeHighlight(entity):
	erase_cell(1, getEntityTile(entity))

func getMouseTile():
	var pos = local_to_map(get_local_mouse_position())
	
	if(get_cell_tile_data(0, pos) == null):
		return Vector2i.MIN
	return pos

func isTileSolid(tile):
	var tileData = get_cell_tile_data(0, tile)
	if tileData.get_custom_data("impassable") == true:
		return true
	return false

#Get a cicle area around a tile
func getTileCircle(pos : Vector2, radius) -> Array:
	var tiles = []
	for y in range(-radius - 1, radius + 1):
		for x in range(-radius - 1, radius + 1):
			if (x * x-1) + (y * y-1) <= (radius * radius):
				tiles.append(Vector2i(pos + Vector2(x, y)))
	
	return tiles

#Get a cicle area around a tile
func getTileRing(pos : Vector2, radius) -> Array:
	var tiles = []
	for y in range(-radius - 1, radius + 1):
		for x in range(-radius - 1, radius + 1):
			if !(x * x) + (y * y) <= (radius * radius)/1.4 and (x * x-1) + (y * y-1) <= (radius * radius):
				tiles.append(Vector2i(pos + Vector2(x, y)))

	return tiles

func targetTiles(tiles, emptyTiles):
	set_cells_terrain_connect(1, tiles, 0, 0, true)
	set_cells_terrain_connect(1, emptyTiles, 0, 2, true)

func loadTileVFX(pos, effect):
	var VFX = load(effect.VFX).instantiate()
	VFX.position = (pos*64)+Vector2i(32, 32)
	%GameFX.add_child(VFX)

func setTileData(pos, data):
	var loadedData = load(data).new()
	
	if(dataGrid[pos] == null):
		dataGrid[pos] = [loadedData]
		if(getTileEntity(pos) != null):
			loadedData._onSet(getTileEntity(pos))
		
		if(loadedData.VFX != null):
			loadTileVFX(pos, loadedData)
		return
	
	for dataIteration in dataGrid[pos]:
		if dataIteration.name == loadedData.name:
			dataIteration.merge(loadedData)
			return
	
	if(loadedData.VFX != null):
		loadTileVFX(pos, loadedData)
	
func getTileData(pos):
	return dataGrid[pos]


func removeTileEntity(entity):
	entityGrid[getEntityTile(entity)] = null

func setTileEntity(pos, entity):
	entityGrid[pos] = entity

func getTileEntity(pos):
	if entityGrid.has(pos):
		return entityGrid[pos]
	else:
		return null

func getEntityTile(entity):
	return entityGrid.find_key(entity)

func getEntities() -> Array:
	return entities
