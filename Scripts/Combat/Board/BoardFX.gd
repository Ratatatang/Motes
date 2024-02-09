extends TileMap
class_name LevelMap

var grid = {} # for the 2d grid
var dataGrid
var entityGrid

func _ready():
	MasterInfo.currentLevelMap = self
	
	var dimensions = get_used_cells(0)
	
	for cell in dimensions:
		grid[cell] = null
	
	dataGrid = grid.duplicate(true)
	entityGrid = grid.duplicate(true)

func addEntity(entity, gridPos):
	var newEntity = entity.instantiate()
	
	newEntity.AStarGrid = %Services.getAStar()
	newEntity.map = self
	newEntity.global_position = gridPos*64
	entityGrid[Vector2i(gridPos)] = newEntity
	
	%GamePieces.add_child(newEntity)

func highlightEntity(entity):
	set_cell(1, getEntityTile(entity), 0, Vector2i.ZERO)

func removeHighlight(entity):
	erase_cell(1, getEntityTile(entity))

func getMouseTile():
	return local_to_map(get_local_mouse_position())


func setTileData(pos, data):
	dataGrid[pos].merge(data, true)
	
func getTileData(pos):
	return dataGrid[pos]


func removeTileEntity(entity):
	entityGrid[getEntityTile(entity)] = null

func setTileEntity(pos, entity):
	entityGrid[pos] = entity

func getTileEntity(pos):
	return entityGrid[pos]

func getEntityTile(entity):
	return entityGrid.find_key(entity)
