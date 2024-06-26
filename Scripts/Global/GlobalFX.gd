extends Node

#Format is color, outline
var typeColors = {
	null: ["#FFFFFF", "#000000"],
	"None": ["#FFFFFF", "#000000"],
	"Fire": ["#D98321", "#000000"],
	"Water": ["#71C5D6", "#000000"]
}

@rpc("any_peer")
func displayInflictedText(text, position, remote = false):
	if !MasterInfo.singleplayer and !remote:
		displayInflictedText.rpc(text, position, true)
	var numberLabel = Label.new()
	numberLabel.position = position+Vector2(randf_range(-20, 20), randf_range(-20, 20))
	numberLabel.text = text
	numberLabel.z_index = 5
	numberLabel.scale = Vector2(1.5, 1.5)
	
	numberLabel.label_settings = LabelSettings.new()
	numberLabel.label_settings.font_color = "#FFFFFF"
	numberLabel.label_settings.font_size = 18
	numberLabel.label_settings.outline_color = "#000000"
	numberLabel.label_settings.outline_size = 1
	
	call_deferred("add_child", numberLabel)
	
	await numberLabel.resized
	numberLabel.pivot_offset = Vector2(numberLabel.size / 2)
	
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(numberLabel, "position", Vector2(numberLabel.position.x, numberLabel.position.y - 24), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(numberLabel, "position", numberLabel.position, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(numberLabel, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	
	numberLabel.queue_free()

@rpc("any_peer")
func displayDamageNumber(value, position, type = "None", remote = false):
	if !MasterInfo.singleplayer and !remote:
		displayDamageNumber.rpc(value, position, type, true)
	var numberLabel = Label.new()
	numberLabel.position = position+Vector2(randf_range(-20, 20), randf_range(-20, 20))
	numberLabel.text = str(value)
	numberLabel.z_index = 5
	numberLabel.scale = Vector2(1.5, 1.5)
	
	numberLabel.label_settings = LabelSettings.new()
	var colors = typeColors[type]
	numberLabel.label_settings.font_color = colors[0]
	numberLabel.label_settings.font_size = 18
	numberLabel.label_settings.outline_color = colors[1]
	numberLabel.label_settings.outline_size = 1
	
	call_deferred("add_child", numberLabel)
	
	await numberLabel.resized
	numberLabel.pivot_offset = Vector2(numberLabel.size / 2)
	
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(numberLabel, "position", Vector2(numberLabel.position.x, numberLabel.position.y - 24), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(numberLabel, "position", numberLabel.position, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(numberLabel, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	
	numberLabel.queue_free()

@rpc("any_peer")
func displayHealingNumber(value, position, remote = false):
	if !MasterInfo.singleplayer and !remote:
		displayInflictedText.rpc(value, position, true)
	var numberLabel = Label.new()
	numberLabel.position = position+Vector2(randf_range(-20, 20), randf_range(-20, 20))
	numberLabel.text = str(value)
	numberLabel.z_index = 5
	numberLabel.scale = Vector2(1.5, 1.5)
	
	numberLabel.label_settings = LabelSettings.new()
	numberLabel.label_settings.font_color = "#13D300"
	numberLabel.label_settings.font_size = 18
	numberLabel.label_settings.outline_color =  "#000000"
	numberLabel.label_settings.outline_size = 1
	
	call_deferred("add_child", numberLabel)
	
	await numberLabel.resized
	numberLabel.pivot_offset = Vector2(numberLabel.size / 2)
	
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(numberLabel, "position", Vector2(numberLabel.position.x, numberLabel.position.y - 24), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(numberLabel, "position", numberLabel.position, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(numberLabel, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	
	numberLabel.queue_free()
