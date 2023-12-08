extends Button

@onready var timer = $Timer
@onready var returnPos = position
@onready var parent = get_parent()

var cardData

func loadCard():
	pass

# updates all the displays on the card to reflect the data stored

func updateData():
	$Name.text = cardData.name
	$Description.text = cardData.description
	$Element.texture = load("res://Assets/Cards/ElementSymbols/"+cardData.element+".png")
	$Picture.texture = load("res://Assets/Cards/CardImages/Fire/"+cardData.name+".png")
	$APCost.text = str(cardData.cost)
	$PercentChance.text = str(cardData.castChance)
	$CardBacking.color = cardData.color
	

func moveTo():
	global_position = Vector2(-469, 454)
	var tween = create_tween()
	tween.tween_property(self, "position", returnPos, 1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)

# these 2 move the card when you hover over it / move out of it
	
func _on_Card_mouse_entered():
	if(disabled == false):
		var tween = create_tween()
		get_parent().z_index = 1
		tween.tween_property(self, "position", Vector2(self.returnPos.x, self.returnPos.y-20.0), 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)

func _on_Card_mouse_exited():
	if(disabled == false):
		var tween = create_tween()
		get_parent().z_index = 0
		tween.tween_property(self, "position", returnPos, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN) 
