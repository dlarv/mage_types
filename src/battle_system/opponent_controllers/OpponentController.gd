extends Resource
class_name OpponentController 

signal battle_ended(playerWasDefeated: bool)

const TEAM_INDEX = 1

@export var dialog_resource: DialogueData
@export var dialog_ids: Array[BattleTalk]
@export var heal_after_battle := true 

var team := []

var _next_dialog_index := 0

func setup(team: Array) -> void:
	_next_dialog_index = 0
	self.team = team
	dialog_ids.sort_custom(func(a, b): 
		if a.turn == b.turn:
			return not a.displayAfterTurn
		return a.turn < b.turn)

func _on_battle_ended(playerWasDefeated: bool) -> void:
	battle_ended.emit(playerWasDefeated)
	if heal_after_battle:
		for ally in team:
			ally.current_hp = ally.hp

func get_actions(otherTeam: Array) -> Array:
	var actions := []
	actions.resize(len(team))

	for i in range(len(team)):
		if(len(team[i].attacks) == 0):
			actions[i] = null;
		else:
			actions[i] = ActorAction.new(team[i], team[i].attacks[0],[ otherTeam[0] ], TEAM_INDEX);
	return actions;

## Return the id of which dialog option to display.
func get_next_dialog_id(turnCounter: int, isAfterTurn: bool) -> String:
	if dialog_resource == null or len(dialog_ids) == 0: return ""
	var dialog = dialog_ids[_next_dialog_index]

	if dialog.turn != turnCounter or dialog.displayAfterTurn != isAfterTurn: return ""
	if dialog.repeat:
		_next_dialog_index += 1
		_next_dialog_index %= len(dialog_ids)
	else:
		dialog_ids.remove_at(_next_dialog_index)
		if len(dialog_ids) > 0:
			_next_dialog_index %= len(dialog_ids)
	return dialog.id


