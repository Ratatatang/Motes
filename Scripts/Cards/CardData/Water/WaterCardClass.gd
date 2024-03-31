extends CardClass
class_name WaterCard

var color : String = "548FD5"

func _init():
	element = "Water"

func getColor() -> String:
	return color

func setColor(new_color) -> void:
	color = new_color


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
	
	return package
