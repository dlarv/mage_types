extends Object
class_name ActorTurnData

## Datatype for actions selected by BattleActors.
## These are basically like an instance of a _BattleAction.
# public static ActorAction[] Flee = new ActorAction[0]

const EXPRESSION_VARS: PackedStringArray = ["total_dmg", "prev_dmg", "recoil_dmg", "missed", "phobia_dmg"]

var user: BattleActor 
var priority: int 
var action: _BattleAction 
var targets: Array[BattleActor] = []
var team_index: int
var effectiveness: float
var defeated_actors: Array[BattleActor]
var failed_effects: Array[EffectSlot]
var blocking_actors: Array[BattleActor]
var total_dmg: int
var prev_dmg: int
var recoil_dmg: int
var phobia_dmg: int
var missed: bool
var element: ElementalType


func _init(actor: BattleActor, action: _BattleAction, targets: Array[BattleActor], teamIndex: int) -> void:
	self.user = actor
	self.action = action
	if action:
		self.priority = action.priority
	self.targets = targets
	self.team_index = teamIndex
	defeated_actors = []
	blocking_actors = []
	failed_effects = []
	missed = false
	total_dmg = 0
	prev_dmg = 0
	recoil_dmg = 0
	phobia_dmg = 0
	element = ElementManager.Blank


func execute() -> ActorTurnData:
	action.apply_effects(self)
	user.action_used.emit(action)
	return self


static func flee() -> ActorTurnData:
	return ActorTurnData.new(null, null, [], -1)


static func empty(user: BattleActor=null) -> ActorTurnData:
	return ActorTurnData.new(user, null, [], -1)


func is_flee() -> bool:
	return team_index == -1


func is_empty() -> bool:
	return team_index == -2


func get_vars() -> Array[Variant]:
	var output := []
	for key in EXPRESSION_VARS:
		output.append(get(key))
	return output
