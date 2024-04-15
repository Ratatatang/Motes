extends Object
class_name  CardClass

var element : String
var displayName : String
var name : String
var description : String
var expandedDescription : String
var image
var castChance : int
var range : int = 5
var cost : int = 5

var AOERotations : bool = false
var areaOfEffect : Array = [Vector2i.ZERO]

var targeting
var validTargets
var AITags

var color : String

var tileEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int):
	pass
	
var enemyEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int):
	pass

var selfEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int):
	pass

var allyEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int):
	pass

var tileEffectEffect = func (_tile: Vector2i, _entity: Entity, _selfEntity: Entity, currentRotation : int):
	pass

func getElement() -> String:
	return element

func getName() -> String:
	return name

func getDisplayName() -> String:
	return displayName

func getDescription() -> String:
	return description

func getExpandedDescription() -> String:
	return expandedDescription

func getCost() -> int:
	return cost

func getCastChance() -> int:
	return castChance

func getTargeting():
	return targeting

func getValidTargets():
	return validTargets

func getAOERotations() -> bool:
	return false

func getRange() -> int:
	return range

func setElement(new_element) -> void:
	element = new_element

func setName(new_name) -> void:
	name = new_name

func setDisplayName(new_name) -> void:
	displayName = new_name

func setDescription(new_description) -> void:
	description = new_description

func setExpandedDescription(new_description) -> void:
	expandedDescription = new_description

func setCastChance(new_cast_chance) -> void:
	castChance = new_cast_chance

func setCost(new_cost) -> void:
	cost = new_cost
	
func setAOERotations(new_setting) -> void:
	AOERotations = new_setting


func packageToDict() -> Dictionary:
	var package = {}
	package.merge({"element" : element})
	package.merge({"displayName" : displayName})
	package.merge({"name" : name})
	package.merge({"description" : description})
	package.merge({"expandedDescription" : expandedDescription})
	package.merge({"image" : image})
	package.merge({"castChance" : castChance})
	package.merge({"range" : range})
	package.merge({"cost" : cost})
	package.merge({"AOERotations" : AOERotations})
	package.merge({"areaOfEffect" : areaOfEffect})
	package.merge({"validTargets" : element})
	package.merge({"AITags" : AITags})
	package.merge({"color" : color})
	
	return package
