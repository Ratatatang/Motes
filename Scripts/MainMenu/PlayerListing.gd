extends Label

var teamIcons = {
	"Red": "res://Assets/MainMenu/GameSettings/TeamIcons/RedTeam.png",
	"Blue": "res://Assets/MainMenu/GameSettings/TeamIcons/BlueTeam.png",
	"Green": "res://Assets/MainMenu/GameSettings/TeamIcons/GreenTeam.png",
	"Yellow": "res://Assets/MainMenu/GameSettings/TeamIcons/YellowTeam.png",
	"None": "res://Assets/MainMenu/GameSettings/TeamIcons/NoTeam.png"
}

var teamCycle = ["Red", "Blue", "Green", "Yellow"]

var AIPlayer = false
var id
var team = 0

func setPlayerName(newName):
	text = newName

func togglePlayerHost(toggle):
	$HostLabel.visible = toggle

func packageInfo() -> Array:
	return [
		teamCycle[team]
	]

func toggleTeams(toggle : bool):
	if toggle:
		%Team.disabled = false
		%Team.texture_normal = load(teamIcons.get(teamCycle[team]))
	else:
		%Team.disabled = true
		%Team.texture_normal = load(teamIcons.get("None"))

@rpc("any_peer")
func _on_team_pressed(remote = false):
	if team == teamCycle.size()-1:
		team = 0
	else:
		team += 1
	
	%Team.texture_normal = load(teamIcons.get(teamCycle[team]))
	
	if !remote:
		_on_team_pressed.rpc(true)
