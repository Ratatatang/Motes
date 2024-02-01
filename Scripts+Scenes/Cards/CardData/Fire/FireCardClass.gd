extends CardClass
class_name FireCard

#Replace orange with hex value
var fireColor : String = "Orange"
var igniteDuration : int = 3
var color : String = "a80d10"

func _init():
	element = "Fire"

func getFireColor() -> String:
	return fireColor

func getIgniteDuration() -> int:
	return igniteDuration

func getColor() -> String:
	return color

func setFireColor(new_color) -> void:
	fireColor = new_color

func setIgniteDuration(new_duration) -> void:
	igniteDuration = new_duration

func setColor(new_color) -> void:
	color = new_color
