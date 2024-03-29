extends CardClass
class_name FireCard

#Replace orange with hex value
var fireColor : String = "Orange"
var color : String = "a80d10"

func _init():
	element = "Fire"

func getFireColor() -> String:
	return fireColor

func getColor() -> String:
	return color

func setFireColor(new_color) -> void:
	fireColor = new_color

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
	package.merge({"fireColor" : fireColor})
	
	return package
