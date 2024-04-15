extends VBoxContainer

@onready var cardPath = load("res://Scenes/Combat/Card.tscn")

func loadCardsHistory(cardsHistory):
	for child in get_children():
		child.queue_free()
	
	for card in cardsHistory:
		var newCard = cardPath.instantiate()
		newCard.passData(card)
		newCard.uncoverCard()
		newCard.moveLabels()
		newCard.disableUse = true
		add_child(newCard)

func hideHistory():
	for child in get_children():
		child.modulate = Color(1, 1, 1, 0)
