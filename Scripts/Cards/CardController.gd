extends Control

var tweenTo : Vector2

signal cardUsed(card)

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

func coverCard():
	$AnimationPlayer.play("cover")
	SFXHandler.playSFX(load("res://Assets/Cards/SFX/CardFlip.wav"), self)

func resetCard():
	$AnimationPlayer.play("reset")
