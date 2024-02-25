extends Control

@export var disableUse = false

var tweenTo : Vector2

signal cardUsed(card)
signal cardInspect(card)

func _ready():
	$Card/Card.disabled = disableUse

func moveTo():
	$AnimationPlayer.play("flip")

func getData():
	return $Card/Card.cardData
	
func passData(cardData):
	$Card/Card.cardData = cardData
	$Card/Card.cardMaster = self
	$Card/Card.updateData()

func flipCard():
	$AnimationPlayer.play("flip")
	SFXHandler.playSFX(load("res://Assets/Cards/SFX/CardFlip.wav"), self)

func flipInspect():
	$AnimationPlayer.play("flipInspect")
	SFXHandler.playSFX(load("res://Assets/Cards/SFX/CardFlip.wav"), self)

func coverCard():
	$AnimationPlayer.play("cover")
	SFXHandler.playSFX(load("res://Assets/Cards/SFX/CardFlip.wav"), self)

func coverInspect():
	$AnimationPlayer.play("coverInspect")
	SFXHandler.playSFX(load("res://Assets/Cards/SFX/CardFlip.wav"), self)

func resetCard():
	$AnimationPlayer.play("reset")
