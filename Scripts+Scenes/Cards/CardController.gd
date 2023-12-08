extends Control

var tweenTo : Vector2

func moveTo():
	$AnimationPlayer.play("flip")

func getData():
	return $Card/Card.cardData
	
func passData(cardData):
	$Card/Card.cardData = cardData
	$Card/Card.updateData()
