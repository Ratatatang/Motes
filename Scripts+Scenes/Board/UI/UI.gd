extends Control

var outPosition = 352
var downPosition = 540

var cardScene = "res://Scripts+Scenes/Cards/Card.tscn"
@onready var parent = get_parent()

# Statemachine for if hand UI is shown or not

enum stateMachine {
	UP,
	DOWN
}

var fireCards

func _ready():
	randomize()
	var text = FileAccess.open("res://Scripts+Scenes/Cards/fireCards.json", FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(text.get_as_text())

	if parse_result != OK:
		print("Error %s reading fire cards file." % parse_result)
		return

	fireCards = json.get_data()
	
	drawDeckCard()
	drawDeckCard()
	drawDeckCard()
	drawDeckCard()

var state = stateMachine.DOWN

func _input(event):
	if(event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
		_on_Arrow_pressed()

# Updates the AP display

func updateAP(newAP, maxAP):
	$Buttons/APlabel.text = str(newAP)+"/"+str(maxAP)

# Draws a card scene & gives it random data 
# passData is necessary for when you draw a card, don't remove it
 
func drawDeckCard():
	var loadedCard = load(cardScene).instantiate()
	loadedCard.cardData = fireCards.get(parent.drawCard())
	loadedCard.passData()
	$Hand.add_child(loadedCard)
	
# drawRandCard with given data
# use for when you draw a specific card from another card
# dosen't remove anything from the deck
	
func drawCard(data):
	var loadedCard = load(cardScene).instantiate()
	loadedCard.cardData = data
	loadedCard.passData()
	$Hand.add_child(loadedCard)

func moveCard(card):
	$UI.add_child(card)
	$Hand.remove_child(card)
	card.set_position(0,0)

# Draw card button

func _on_DrawButton_pressed():
	var handCount = $Hand.get_child_count()
	
	if(handCount < parent.maxHandSize and parent.enoughAP(1)):
		parent.updateAP(-1)
		drawDeckCard()

# Arrow button

func _on_Arrow_pressed():
	print("ArrowPressed")
	if(state == stateMachine.DOWN):
		var tween = create_tween()
		tween.tween_property(self, "position", Vector2(0, outPosition), 0.4).set_trans( Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
		state = stateMachine.UP
		$Arrow.flip_v = !($Arrow.flip_v)
		
	elif(state == stateMachine.UP):
		var tween = create_tween()
		$Tween.interpolate_property(self, "position", Vector2(0, downPosition), 0.4).set_trans( Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
		state = stateMachine.DOWN
		$Arrow.flip_v = !($Arrow.flip_v)

