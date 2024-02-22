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
	$Name.text = cardData.displayName
	$Description.text = cardData.description
	$Element.texture = load("res://Assets/Cards/ElementSymbols/"+cardData.element+".png")
	$Picture.texture = load("res://Assets/Cards/CardImages/Fire/"+cardData.name+".png")
	$APCost.text = str(cardData.cost)
	$PercentChance.text = str(cardData.castChance)
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
	
# these 2 move the card when you hover over it / move out of it
func _on_Card_mouse_entered():
	if(disabled == false and selected == false):
		var tween = create_tween()
		get_parent().z_index = 1
		tween.tween_property(self, "position", Vector2(self.returnPos.x, self.returnPos.y-20.0), 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)

func _on_Card_mouse_exited():
	if(disabled == false and selected == false):
		var tween = create_tween()
		get_parent().z_index = 0
		tween.tween_property(self, "position", returnPos, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN) 

func _on_pressed():
	if(disabled == false):
		cardMaster.cardUsed.emit(self)
