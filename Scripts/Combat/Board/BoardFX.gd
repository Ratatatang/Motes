extends TileMap
class_name LevelMap

var grid = {} # for the 2d grid
var dataGrid
var entityGrid

var entities = []

var mouseHighlights = []

@export var teamSpawnPoints : Dictionary = {
	0: [Vector2(1, 6), Vector2(1, 7), Vector2(1, 8), Vector2(2, 6), Vector2(2, 7), Vector2(2, 8)],
	1: [Vector2(14, 1), Vector2(13, 1), Vector2(12, 1), Vector2(14, 2), Vector2(13, 2), Vector2(12, 2)],
	2: [Vector2(11, 14), Vector2(10, 14), Vector2(9, 14), Vector2(11, 15), Vector2(10, 15), Vector2(9, 15)],
	3: [Vector2(24, 6), Vector2(24, 7), Vector2(24, 8), Vector2(25, 6), Vector2(25, 7), Vector2(25, 8)],
	4: [Vector2(13, 6), Vector2(13, 5), Vector2(13, 7), Vector2(12, 6), Vector2(14, 6), Vector2(14, 7),]
}

@export var startingTileObjects : Dictionary = {}

func _ready():
	MasterInfo.currentLevelMap = self
	
	var dimensions = get_used_cells(0)
	
	for cell in dimensions:
		grid[cell] = null
	
	dataGrid = grid.duplicate(true)
	entityGrid = grid.duplicate(true)

@rpc("any_peer", "call_local") 
func addEntity(entity, gridPos, parentID, team = "Player", randID = randi()):
	var newEntity = load(entity).instantiate()
	
	newEntity.AStarGrid = %Services.getAStar()
	newEntity.characterPassableMap = %Services.getAStarGridAIPassable()
	newEntity.AStarGridAI = %Services.getAStarAI()
	newEntity.map = self
	newEntity.setTeam(team)
	newEntity.parentID = parentID
	newEntity.global_position = gridPos*64
	
	newEntity.entityID = randID
	
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

@rpc("any_peer", "call_local")
func highlightTile(tilePos):
	set_cell(1, tilePos, 2, Vector2i(0, 3))

func removeHighlight(entity):
	erase_cell(1, getEntityTile(entity))

@rpc("any_peer", "call_local")
func removeHighlightTile(tilePos):
	erase_cell(1, tilePos)

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

func advanceTileTimers():
	for tile in dataGrid.values():
		if tile != null and tile != []:
			for effect in tile:
				effect.advanceTimer()

@rpc("any_peer")
func setTileData(pos, data):
	var loadedData = load(data).instantiate()
	
	if(dataGrid[pos] == null or dataGrid[pos] == []):
		dataGrid[pos] = [loadedData]
		%GamePieces.add_child(loadedData)
		loadedData.position = (pos*64)+Vector2i(32, 32)
		
		if multiplayer.get_unique_id() == 1:
			setTileDataRemote.rpc(pos, data)
		
		if(getTileEntity(pos) != null):
			loadedData._onSet(getTileEntity(pos))
		return
	
	for dataIteration in dataGrid[pos]:
		if dataIteration.name == loadedData.name:
			dataIteration.merge(loadedData)
			return

@rpc("any_peer")
func setTileDataRemote(pos, data):
	var loadedData = load(data).instantiate()
	
	dataGrid[pos] = [loadedData]
	%GamePieces.add_child(loadedData)
	loadedData.position = (pos*64)+Vector2i(32, 32)

func getTileData(pos):
	if entityGrid.has(pos):
		return dataGrid[pos]
	else:
		return null

func removeDataFromTile(data):
	for tile in dataGrid.values():
		if tile != null and tile != []:
			if tile.has(data):
				tile.erase(data)

@rpc("any_peer")
func removeTileEntity(entity):
	var entityPos = getEntityTile(entity)
	entityGrid[entityPos] = null
	
	if multiplayer.get_unique_id() == 1:
		removeTileEntityRemote.rpc(entityPos)

@rpc("any_peer")
func removeTileEntityRemote(entityPos):
	entityGrid[entityPos] = null
	return

@rpc("any_peer")
func setTileEntity(pos, entity):
	entityGrid[pos] = entity
	
	if multiplayer.get_unique_id() == 1:
		setTileEntityRemote.rpc(pos, entity.entityID)

@rpc("any_peer")
func setTileEntityRemote(pos, entityID):
	for entity in entities:
		if entity.entityID == entityID:
			entityGrid[pos] = entity
			return

func getTileEntity(pos):
	if entityGrid.has(pos):
		return entityGrid[pos]
	else:
		return null

func getEntityTile(entity):
	return entityGrid.find_key(entity)

func getEntities() -> Array:
	return entities
