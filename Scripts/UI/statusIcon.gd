extends Control

func loadStatus(status):
	$statusIcon/Status.texture = load(status.statusIcon)
	$statusIcon/Name.text = "[center]"+ status.statusName +"[/center]"
	$statusIcon/Turns.text = str(status.timer-status.countdown)
