extends Button

@onready var timer = $Timer

@onready var returnPos = self.position

var cardData
var color

func loadCard():
	pass

# updates all the displays on the card to reflect the data stored

func updateData():
	$Name.text = cardData.get("Name")
	$Description.text = cardData.get("Description")
	$Element.texture = load("res://Assets/Cards/ElementSymbols/"+cardData.get("Element")+".png")
	$Picture.texture = load("res://Assets/Cards/CardImages/"+cardData.get("Element")+"/"+cardData.get("Element")+"CardPics.png")
	$Picture.frame = cardData.get("PicFrame")
	$APCost.text = str(cardData.get("Cost"))
	$PercentChance.text = str(cardData.get("CastChance"))
	$CardBacking.color = color
	
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
