extends OpponentController
class_name ScriptedOpponent
## Cycles through each of its actors movesets.
## Targets are randomly selected.

const TargetType := _BattleAction.TargetType

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


func get_actions(otherTeam: Array[BattleActor]) -> Array[ActorAction]:
	var actions: Array[ActorAction]= []
	var i := -1
	for actor in team:
		i += 1

		indices[i] += 1
		indices[i] %= len(actor.attacks)
		var index := indices[i]

		var attack := actor.attacks[index]
		var target: Array[BattleActor]
		match attack.target:
			TargetType.ENEMY, TargetType.ENEMIES:
				target = [otherTeam.pick_random()]
			TargetType.ALLY, TargetType.ALLIES:
				target = [team.pick_random()]
			TargetType.SELF:
				target = [actor]
			TargetType.ALL:
				target = team + otherTeam
			TargetType.ANY, TargetType.RANDOM:
				target = [(team + otherTeam).pick_random()]

		actions.append(ActorAction.new(actor, attack, target, TEAM_INDEX))
		actor.action_selected.emit(attack)
	
	return actions

		
func _on_battle_ended(playerWasDefeated: Battle.EndState) -> void:
	battle_ended.emit(playerWasDefeated)
	if not set_seed.is_empty():
		seed(_initial_seed)
