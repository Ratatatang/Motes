extends Object
class_name  CardClass

var element : String
var displayName : String
var name : String
var description : String
var image
var castChance : int
var cost : int
var targeting

func _OnTileEffect(target: LevelMap):
	pass
	
func _OnEnemyEffect(target: Entity):
	pass

func getElement() -> String:
	return element

func getName() -> String:
	return name

func getDisplayName() -> String:
	return displayName

func getDescription() -> String:
	return element

func getCost() -> int:
	return cost

func getCastChance() -> int:
	return castChance

func setElement(new_element) -> void:
	element = new_element

func setName(new_name) -> void:
	name = new_name

func setDisplayName(new_name) -> void:
	displayName = new_name

func setDescription(new_description) -> void:
	description = new_description

func setCastChance(new_cast_chance) -> void:
	castChance = new_cast_chance

func setCost(new_cost) -> void:
	cost = new_cost