extends VBoxContainer

@onready var statusIcon = load("res://Scenes/UI/statusIcon.tscn")

func loadStatusIcons(statusList):
	for child in get_children():
		child.queue_free()
		
	for status in statusList:
		var newStatus = statusIcon.instantiate()
		newStatus.loadStatus(status)
		add_child(newStatus)

func animateStatusIcons():
	var tween = create_tween()
	for child in get_children():
		
		child.visible = true
		child.position += Vector2(20, 0)
		child.modulate = Color(1, 1, 1, 0)
		
		tween.tween_property(child, "position", Vector2(child.position.x-20, child.position.y), 0.3)
		tween.parallel().tween_property(child, "modulate", Color(1, 1, 1, 1), 0.3)

func hideStatusIcons():
	for child in get_children():
		child.modulate = Color(1, 1, 1, 0)
