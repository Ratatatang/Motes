extends Control

var outPosition = 433
var downPosition = 555
var loggedMousePos = Vector2(0,0)

var raiseIgnore = false
var raiseDisabled = false
var currentlyDown = true
var cardsDisabled = false

var cardScene = "res://Scenes/Combat/Card.tscn"

func _input(event):
	if(event.is_action_pressed("space")):
		raiseDisabled = false
		if(raiseIgnore == true):
			raiseIgnore = false
			_on_area_2d_mouse_entered()
		else:
			_on_area_2d_mouse_entered()
			raiseIgnore = true

func updateLabels():
	updateAPLabel()
	updateCardsLabel()

func updateAPLabel():
	$CardBack/APLabel.text = "AP:  "+str(%Services.getCurAP())+"/"+str(%Services.getMaxAP())
	
func updateCardsLabel():
	$CardBack/CardsLabel.text = "Cards Left:  "+str(%Services.getCurDeck().size())

# drawRandCard with given data
# use for when you draw a specific card from another card
# dosen't remove anything from the deck
	
func drawCard(data):
	var loadedCard = load(cardScene).instantiate()
	loadedCard.passData(data)
	loadedCard.connect("cardUsed", Callable(self, "useCard"))
	loadedCard.connect("cardInspect", Callable(self, "cardInspect"))
	%Hand.add_child(loadedCard)
	if(%Hand.get_child_count() > 9):
		for card in %Hand.get_children():
			var offset = 3*(%Hand.get_child_count())
			card.custom_minimum_size = Vector2(80, 0)-Vector2(offset, 0)
			
	loadedCard.moveTo()

func moveCard(card):
	add_child(card)
	%Hand.remove_child(card)
	card.set_position(0,0)

func setDown():
	if(!currentlyDown):
		raiseIgnore = false
		_on_area_2d_mouse_entered()

func loadHand(entity):
	for card in %Hand.get_children():
		card.queue_free()
	
	for card in entity.hand:
		drawCard(card)

func useCard(card):
	if(!cardsDisabled):
		%Combat.setAction(3)
		%Services.loadCard(card)
		%Services.drawValidTargets(card)
		setDown()
		visible = false

func cardInspect(card):
	%Combat.setAction(4)
	%Services.inspectCard(card)
	setDown()
	visible = false

func enableUI():
	visible = true
	var tween = create_tween()
	var moveTo = position
	position += Vector2(0, 35)
	tween.tween_property(self, "position", moveTo, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func disableMove():
	$Buttons/Move.disabled = true

func enableMove():
	$Buttons/Move.disabled = false

func disableCards():
	cardsDisabled = true

func enableCards():
	cardsDisabled = false

func enableShuffle():
	$Buttons/Draw.visible = false
	$Buttons/Shuffle.visible = true
	
func disableShuffle():
	$Buttons/Draw.visible = true
	$Buttons/Shuffle.visible = false

func _on_DrawButton_pressed():
	%Services.drawCard()
	updateCardsLabel()

func _on_end_turn_pressed():
	if !MasterInfo.singleplayer:
		%Services.advanceTurn.rpc_id(1)
	else:
		%Services.advanceTurn()

func _on_move_pressed():
	%Combat.setAction(2)
	%Services.enableLine()
	setDown()
	visible = false

func _on_shuffle_pressed():
	%Services.shuffleDeck()
	disableShuffle()
	updateCardsLabel()

func _on_status_pressed():
	%Combat.setAction(5)
	%Services.openStatus()
	setDown()
	visible = false

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



