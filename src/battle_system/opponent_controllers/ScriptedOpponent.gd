extends OpponentController
class_name ScriptedOpponent
## Cycles through each of its actors movesets.
## Targets are randomly selected.


@export var set_seed := ""

var indices: Array[int] = []
var _initial_seed := -1

func setup(team: Array[BattleActor]) -> void:
	if not set_seed.is_empty():
		_initial_seed = Settings.random_seed
		seed(set_seed.hash())
	super.setup(team)
	
	indices = []
	for i in team:
		indices.append(-1)


func get_actions(otherTeam: Array[BattleActor]) -> Array[ActorTurnData]:
	var actions: Array[ActorTurnData]= []
	var i := -1
	for actor in team:
		i += 1

		indices[i] += 1
		indices[i] %= len(actor.attacks)
		var index := indices[i]

		var attack := actor.attacks[index]
		var target := _get_random_targets(attack, actor, otherTeam)

		actions.append(ActorTurnData.new(actor, attack, target, TEAM_INDEX))
		actor.action_selected.emit(attack)

		var targetName := ",".join(target.map(func(t: BattleActor) -> String: return t.name))
		MyLogger.append_battle_ai_log("%s is using %s against %s.\n"
				% [actor.name, attack.name, targetName])
	
	return actions

		
func _on_battle_ended(playerWasDefeated: Battle.EndState) -> void:
	battle_ended.emit(playerWasDefeated)
	if not set_seed.is_empty():
		seed(_initial_seed)
