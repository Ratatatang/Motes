extends TileMap
class_name LevelMap

var grid = {} # for the 2d grid
var dataGrid
var entityGrid

var entities = []

var mouseHighlights = []

func _ready():
	MasterInfo.currentLevelMap = self
	
	var dimensions = get_used_cells(0)
	
	for cell in dimensions:
		grid[cell] = null
	
	dataGrid = grid.duplicate(true)
	entityGrid = grid.duplicate(true)

func addEntity(entity, gridPos, team = "Player"):
	var newEntity = entity.instantiate()
	
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

func highlightEntity(entity):
	set_cell(1, getEntityTile(entity), 2, Vector2i(0, 3))

func removeHighlight(entity):
	erase_cell(1, getEntityTile(entity))

func getMouseTile():
	var pos = local_to_map(get_local_mouse_position())
	
	if(get_cell_tile_data(0, pos) == null):
		return Vector2i.MIN
	return pos

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

func targetTiles(tiles):
	set_cells_terrain_connect(1, tiles, 0, 0, true)

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
