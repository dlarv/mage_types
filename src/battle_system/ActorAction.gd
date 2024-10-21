extends Node
class_name ActorAction 

## Datatype for actions selected by BattleActors.
## These are basically like an instance of a BattleAction.
# public static ActorAction[] Flee = new ActorAction[0]

var actor: BattleActor 
var priority: int 
var action: BattleAction 
# BattleActor[]
var targets := []
var team_index: int

func _init(actor: BattleActor, action: BattleAction, targets: Array, teamIndex: int) -> void:
	if actor == null: return
	self.actor = actor
	self.action = action
	self.priority = action.priority
	self.targets = targets
	self.team_index = teamIndex

static func flee():
	return ActorAction.new(null, null, [], -1)

func is_flee():
	return actor == null

static func compare_to(a: ActorAction, b: ActorAction) -> bool: 
	# Higher priority goes first.
	if a.priority != b.priority:
		return a.priority > b.priority
	# Then higher speed goes first.
	if a.actor.speed != b.actor.speed:
		return a.actor.speed > b.actor.speed
	return randf() < 0.5
