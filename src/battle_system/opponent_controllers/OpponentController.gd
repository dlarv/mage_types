extends Resource
class_name OpponentController 

signal battle_ended(endState: Battle.EndState)

const ActorAction := preload("res://src/battle_system/ActorAction.gd")
const TargetType := _BattleAction.TargetType
const TEAM_INDEX := 1

@export_category("Dialog")
@export var dialog_resource: DialogueData
@export var dialog_ids: Array[BattleTalk]

@export_category("Battle Rewards")
@export var reward_xp: float
@export var reward_items: Array[ItemSlot]

var team: Array[BattleActor] = []

var _next_dialog_index := 0

func setup(team: Array[BattleActor]) -> void:
	_next_dialog_index = 0
	self.team = team

	var counter := {}
	dialog_ids.sort_custom(func(a: BattleTalk, b: BattleTalk) -> bool: 
		if not counter.has(a):
			counter[a] = true
			a.init_story_interface(team[0])
		if not counter.has(b):
			counter[b] = true
			b.init_story_interface(team[0])

		if a.turn == b.turn:
			return not a.displayAfterTurn
		return a.turn < b.turn)


func _on_battle_ended(endState: Battle.EndState) -> void:
	battle_ended.emit(endState)


func get_actions(otherTeam: Array[BattleActor]) -> Array[ActorAction]:
	var actions: Array[ActorAction] = []
	actions.resize(len(team))

	for i in range(len(team)):
		if(len(team[i].attacks) == 0):
			actions[i] = null
		else:
			var attack: Attack = team[i].attacks.pick_random()
			var target := _get_random_targets(attack, team[i], otherTeam)
			actions[i] = ActorAction.new(
				team[i], 
				attack,
				target,  
				TEAM_INDEX
			)
			team[i].action_selected.emit(attack)

			var targetName := ",".join(target.map(func(t: BattleActor) -> String: return t.name))

			Logger.append_battle_ai_log("%s is using %s against %s.\n"
					% [team[i].name, attack.name, targetName])
	return actions


## Return the id of which dialog option to display.
func get_next_dialog_id(turnCounter: int, isAfterTurn: bool) -> String:
	if dialog_resource == null or len(dialog_ids) == 0: return ""
	var dialog := dialog_ids[_next_dialog_index]

	if dialog.turn != turnCounter or dialog.displayAfterTurn != isAfterTurn: return ""
	if dialog.repeat:
		_next_dialog_index += 1
		_next_dialog_index %= len(dialog_ids)
	else:
		dialog_ids.remove_at(_next_dialog_index)
		if len(dialog_ids) > 0:
			_next_dialog_index %= len(dialog_ids)
	return dialog.id

func _get_random_targets(attack: Attack, user: BattleActor, otherTeam: Array[BattleActor]) -> Array[BattleActor]:
	match attack.target:
		TargetType.ENEMY, TargetType.ENEMIES:
			return [otherTeam.pick_random()]
		TargetType.ALLY, TargetType.ALLIES:
			return [team.pick_random()]
		TargetType.SELF:
			return [user]
		TargetType.ALL:
			return team + otherTeam
		TargetType.ANY, TargetType.RANDOM,_:
			return [(team + otherTeam).pick_random()]

