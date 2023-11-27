extends Control

var cardData

func getData():
	return $Card/Card.cardData
	
func passData():
	$Card/Card.cardData = cardData
	$Card/Card.updateData()
