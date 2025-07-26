extends Node
class_name ActorAction 

## Datatype for actions selected by BattleActors.
## These are basically like an instance of a _BattleAction.
# public static ActorAction[] Flee = new ActorAction[0]

var actor: BattleActor 
var priority: int 
var action: _BattleAction 
# BattleActor[]
var targets: Array[BattleActor] = []
var team_index: int

func _init(actor: BattleActor, action: _BattleAction, targets: Array[BattleActor], teamIndex: int) -> void:
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

