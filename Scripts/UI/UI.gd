extends Control

var outPosition = 433
var downPosition = 555
var loggedMousePos = Vector2(0,0)

var raiseIgnore = false
var raiseDisabled = false
var currentlyDown = true

var cardScene = "res://Scenes/Combat/Card.tscn"


var cardsDirectory

func _ready():
	randomize()
	var text = FileAccess.open("res://Scripts/Cards/CardData/CardDirectory.json", FileAccess.READ)
	var json = JSON.new()
	var parse_result = json.parse(text.get_as_text())

	if parse_result != OK:
		print("Error %s reading cards directory." % parse_result)
		return

	cardsDirectory = json.get_data()


func _input(event):
	if(event.is_action_pressed("space")):
		raiseDisabled = false
		if(raiseIgnore == true):
			raiseIgnore = false
			_on_area_2d_mouse_entered()
		else:
			_on_area_2d_mouse_entered()
			raiseIgnore = true

func updateAPLabel():
	$CardBack/APLeft.text = "AP:  "+str(%Services.getCurAP())+"/"+str(%Services.getMaxAP())

# Draws a card scene & gives it random data 
# passData is necessary for when you draw a card, don't remove it
 
func drawDeckCard():
	var loadedCard = load(cardScene).instantiate()
	var object = load(cardsDirectory.get(%Services.drawCard())).new()
	loadedCard.passData(object)
	loadedCard.visible = false
	%Hand.add_child(loadedCard)
	loadedCard.moveTo()

# drawRandCard with given data
# use for when you draw a specific card from another card
# dosen't remove anything from the deck
	
func drawCard(data):
	var loadedCard = load(cardScene).instantiate()
	loadedCard.cardData = data
	loadedCard.passData()
	loadedCard.cardUsed.connect(cardUsed)
	%Hand.add_child(loadedCard)

func moveCard(card):
	add_child(card)
	%Hand.remove_child(card)
	card.set_position(0,0)

func cardUsed(card):
	print("click!")

func setDown():
	if(!currentlyDown):
		raiseIgnore = false
		_on_area_2d_mouse_entered()

func _on_DrawButton_pressed():
	var handCount = %Hand.get_child_count()
	
	if(handCount < %Services.getMaxHandSize() and %Services.enoughAP(1)):
		%Services.decrementAP(1)
		drawDeckCard()

func _on_end_turn_pressed():
	%Services.advanceTurn()

func _on_area_2d_mouse_entered():
	if(raiseDisabled == true):
		return
	
	var tween = create_tween()
	
	if(raiseIgnore == true):
		raiseIgnore = false
		
	if(currentlyDown):
		tween.tween_property(self, "position", Vector2(0, outPosition), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await tween.finished
		currentlyDown = false
		
	elif(!currentlyDown):
		tween.tween_property(self, "position", Vector2(0, downPosition), 0.35).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		await tween.finished
		currentlyDown = true
