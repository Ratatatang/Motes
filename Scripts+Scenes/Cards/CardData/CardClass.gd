class_name  CardClass

var element : String
var title : String
var description : String
var image
var castChance : int
var cost : int
var targeting

func getElement() -> String:
	return element

func getTitle() -> String:
	return title

func getDescription() -> String:
	return element

func getCost() -> int:
	return cost

func getCastChance() -> int:
	return castChance

func setElement(new_element) -> void:
	element = new_element

func setTitle(new_title) -> void:
	title = new_title

func setDescription(new_description) -> void:
	description = new_description

func setCastChance(new_cast_chance) -> void:
	castChance = new_cast_chance

func setCost(new_cost) -> void:
	cost = new_cost
