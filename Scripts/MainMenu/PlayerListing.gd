extends Label

func setPlayerName(newName):
	text = newName

func togglePlayerHost(toggle):
	$HostLabel.visible = toggle
