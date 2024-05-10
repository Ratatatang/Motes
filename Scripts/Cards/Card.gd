extends Button

@onready var timer = $Timer
@onready var returnPos = position

var cardMaster

var selected = false

var cardData

func loadCard():
	pass

# updates all the displays on the card to reflect the data stored

func updateData():
	$Name.text = "[center]%s[/center]" % cardData.displayName
	$Description.text = "[center]%s[/center]" % cardData.description
	$ExpandedDescription/Description.text = "[center]%s[/center]" % cardData.expandedDescription
	$ElementLabel/Element.texture = load("res://Assets/Cards/ElementSymbols/%s.png" % cardData.element)
	$Picture.texture = load("res://Assets/Cards/CardImages/%s/%s.png" % [cardData.element, cardData.name])
	$CostLabel/APCost.text = str(cardData.cost)
	$ChanceLabel/CastChance.text = str(cardData.castChance)
	$RangeLabel/Range.text = str(cardData.range)
	$CardSprite.self_modulate = cardData.color

func moveTo():
	global_position = Vector2(-469, 454)
	var tween = create_tween()
	tween.tween_property(self, "position", returnPos, 1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)

func unselect():
	selected = false
	_on_Card_mouse_exited()

func freeSelf():
	cardMaster.queue_free()

func getElement():
	return cardData.element

func getDisplayName():
	return cardData.displayName

func getName():
	return cardData.name

func getDescription():
	return cardData.description

func getCastChance():
	return cardData.castChance

func getRange():
	return cardData.range

func getCost():
	return cardData.cost

func getAreaOfEffect():
	return cardData.areaOfEffect

func getTargeting():
	return cardData.targeting
	
func getValidTargets():
	return cardData.validTargets

func getAOERotations():
	return cardData.AOERotations

func packageToDict():
	return cardData.packageToDict()

func moveLabels():
	$CostLabel.position = Vector2(70+(7*$CostLabel/APCost.text.length()), 10)
	$ElementLabel.position = Vector2(85, 40)
	$ChanceLabel.position = Vector2(77+(10*$ChanceLabel/CastChance.text.length()), 70)
	$RangeLabel.position = Vector2(80+(10*$RangeLabel/Range.text.length()), 100)

func showLabels():
	var tween = create_tween()
	
	tween.tween_property($CostLabel, "position", Vector2(70+(7*$CostLabel/APCost.text.length()), 10), 0.1)
	tween.tween_property($ElementLabel, "position", Vector2(85, 40), 0.1)
	tween.tween_property($ChanceLabel, "position", Vector2(77+(10*$ChanceLabel/CastChance.text.length()), 70), 0.1)
	tween.tween_property($RangeLabel, "position", Vector2(80+(10*$RangeLabel/Range.text.length()), 100), 0.1)

func hideLabels():
	var tween = create_tween()
	
	tween.tween_property($CostLabel, "position", Vector2(46, 10), 0.01)
	tween.tween_property($ElementLabel, "position", Vector2(46, 40), 0.01)
	tween.tween_property($ChanceLabel, "position", Vector2(46, 70), 0.01)
	tween.tween_property($RangeLabel, "position", Vector2(46, 100), 0.01)

# these 2 move the card when you hover over it / move out of it
func _on_Card_mouse_entered():
	if(disabled == false and selected == false):
		var tween = create_tween()
		get_parent().z_index = 1
		tween.tween_property(self, "position", Vector2(self.returnPos.x, self.returnPos.y-20.0), 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
		
		tween.tween_property($CostLabel, "position", Vector2(70+(7*$CostLabel/APCost.text.length()), 10), 0.1)
		tween.tween_property($ElementLabel, "position", Vector2(85, 40), 0.1)
		tween.tween_property($ChanceLabel, "position", Vector2(77+(10*$ChanceLabel/CastChance.text.length()), 70), 0.1)
		tween.tween_property($RangeLabel, "position", Vector2(80+(10*$RangeLabel/Range.text.length()), 100), 0.1)

func _on_Card_mouse_exited():
	if(disabled == false and selected == false):
		var tween = create_tween()
		get_parent().z_index = 0
		tween.tween_property(self, "position", returnPos, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
		
		tween.tween_property($CostLabel, "position", Vector2(46, 10), 0.1)
		tween.tween_property($ElementLabel, "position", Vector2(46, 40), 0.1)
		tween.tween_property($ChanceLabel, "position", Vector2(46, 70), 0.1)
		tween.tween_property($RangeLabel, "position", Vector2(46, 100), 0.1)

func _on_gui_input(event):
	if(disabled == false):
		if(event.is_action_pressed("leftClick")):
			cardMaster.cardUsed.emit(self)
		if(event.is_action_pressed("rightClick")):
			cardMaster.cardInspect.emit(cardData)
