extends ScriptedOpponent

var _turn_counter := 0

func setup(team: Array) -> void:
	super.setup(team)
	_turn_counter = 0

func get_actions(otherTeam: Array) -> Array:
	_turn_counter += 1

	return super.get_actions(otherTeam)

