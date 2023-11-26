extends Control

@onready var playerNode = get_parent().find_child("Player")

var outPosition = 352
var downPosition = 540

var cardScene = "res://Combat/Card.tscn"

# Statemachine for if hand UI is shown or not

enum stateMachine {
	UP,
	DOWN
}

var fireCards

func _ready():
	randomize()
	var text = FileAccess.open("res://Combat/CardParts/fireCards.json", FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(text.get_as_text())

	if parse_result != OK:
		print("Error %s reading pokedex file." % parse_result)
		return

	fireCards = json.get_data()
	
	drawRandCard()
	drawRandCard()
	drawRandCard()
	drawRandCard()

var state = stateMachine.DOWN

# Updates the AP display

func updateAP(newAP, maxAP):
	$Buttons/APlabel.text = str(newAP)+"/"+str(maxAP)

# Draws a card scene & gives it random data 
# passData is necessary for when you draw a card, don't remove it
 
func drawRandCard():
	var loadedCard = load(cardScene).instantiate()
	loadedCard.cardData = playerNode.getRandCard()
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
	
	if(handCount < playerNode.maxHandSize and playerNode.enoughStamina(1)):
		playerNode.updateStamina(-1)
		drawRandCard()

# Arrow button

func _on_Arrow_pressed():
	if(state == stateMachine.DOWN):
		$Tween.interpolate_property(self, "position", self.position, Vector2(0, outPosition), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		$Tween.start()
		state = stateMachine.UP
		$Arrow.flip_v = !($Arrow.flip_v)
		
	elif(state == stateMachine.UP):
		$Tween.interpolate_property(self, "position", self.position, Vector2(0, downPosition), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		$Tween.start()
		state = stateMachine.DOWN
		$Arrow.flip_v = !($Arrow.flip_v)

