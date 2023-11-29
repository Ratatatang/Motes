extends Control

var cardData
var elementColors = {
	"null": "707070",
	"Fire": "a80d10",
	"Water": "0c39ab"
}

func getData():
	return $Card/Card.cardData
	
func passData():
	$Card/Card.cardData = cardData
	$Card/Card.color = elementColors.get(cardData.get("Element"))
	$Card/Card.updateData()
