extends Control

@onready var handNode = $Hand
@onready var parent = get_parent()

var outPosition = 352
var downPosition = 525
var loggedMousePos = Vector2(0,0)

var raiseIgnore = false
var raiseDisabled = false

var cardScene = "res://Scripts+Scenes/Cards/Card.tscn"

# Statemachine for if hand UI is shown or not

enum stateMachine {
	UP,
	DOWN
}

var cardsDirectory

func _ready():
	randomize()
	var text = FileAccess.open("res://Scripts+Scenes/Cards/CardData/CardDirectory.json", FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(text.get_as_text())

	if parse_result != OK:
		print("Error %s reading cards directory." % parse_result)
		return

	cardsDirectory = json.get_data()

var state = stateMachine.DOWN

func _input(event):
	if(event.is_action_pressed("space")):
		raiseDisabled = false
		if(raiseIgnore == true):
			raiseIgnore = false
			_on_area_2d_mouse_entered()
		else:
			_on_area_2d_mouse_entered()
			raiseIgnore = true
		
func _physics_process(delta):
	if(loggedMousePos == get_global_mouse_position()):
		pass
	else:
		pass
		
func dealHand():
	drawDeckCard()
	drawDeckCard()
	drawDeckCard()
	drawDeckCard()

# Draws a card scene & gives it random data 
# passData is necessary for when you draw a card, don't remove it
 
func drawDeckCard():
	var loadedCard = load(cardScene).instantiate()
	var object = load(cardsDirectory.get(parent.drawCard())).new()
	loadedCard.passData(object)
	loadedCard.visible = false
	handNode.add_child(loadedCard)
	loadedCard.moveTo()

# drawRandCard with given data
# use for when you draw a specific card from another card
# dosen't remove anything from the deck
	
func drawCard(data):
	var loadedCard = load(cardScene).instantiate()
	loadedCard.cardData = data
	loadedCard.passData()
	handNode.add_child(loadedCard)

func moveCard(card):
	$UI.add_child(card)
	handNode.remove_child(card)
	card.set_position(0,0)

func setDown():
	if(state == stateMachine.UP):
		raiseIgnore = false
		_on_area_2d_mouse_entered()

func _on_DrawButton_pressed():
	var handCount = handNode.get_child_count()
	
	if(handCount < parent.maxHandSize and parent.enoughAP(1)):
		parent.incrementAP(-1)
		drawDeckCard()

func _on_area_2d_mouse_entered():
	if(raiseDisabled == true):
		return
	
	var tween = create_tween()
	
	if(raiseIgnore == true):
		raiseIgnore = false
		
	elif(state == stateMachine.DOWN):
		tween.tween_property(self, "position", Vector2(0, outPosition), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await tween.finished
		state = stateMachine.UP
		
	elif(state == stateMachine.UP):
		tween.tween_property(self, "position", Vector2(0, downPosition), 0.35).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		await tween.finished
		state = stateMachine.DOWN
	
