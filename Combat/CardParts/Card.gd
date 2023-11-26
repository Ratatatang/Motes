extends Button

@onready var timer = $Timer

@onready var returnPos = self.position

var cardData

func loadCard():
	pass

# updates all the displays on the card to reflect the data stored

func updateData():
	$Name.text = cardData.get("Name")
	$Description.text = cardData.get("Description")
	$Element.texture = load("res://Combat/CardParts/ElementSymbols/"+cardData.get("Element")+".png")
	$Picture.texture = load("res://Combat/CardParts/"+cardData.get("Element")+"CardPics.png")
	$Picture.frame = cardData.get("PicFrame")
	$APCost.text = String(cardData.get("Cost"))
	
# these 2 move the card when you hover over it / move out of it
	
func _on_Card_mouse_entered():
	if(disabled == false):
		get_parent().z_index = 1
		$Tween.interpolate_property(self, "position", self.position, Vector2(self.returnPos.x, self.returnPos.y-20.0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		$Tween.start()

func _on_Card_mouse_exited():
	if(disabled == false):
		get_parent().z_index = 0
		$Tween.interpolate_property(self, "position", self.position, returnPos, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		$Tween.start()
