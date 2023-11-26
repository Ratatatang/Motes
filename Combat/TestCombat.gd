extends Node2D

func ready():
	randomize()
	
func setStaminaLabel(maxS, tempS):
	$UI/Buttons/Staminalabel.text = str(tempS) + "/" + str(maxS)

func useCard(card):
	pass

