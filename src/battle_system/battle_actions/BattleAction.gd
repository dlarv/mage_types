@tool
extends Resource 
class_name BattleAction 

# public static BattleAction Flee { get private set } = new()

enum TargetType { Self, Ally, Allies, Enemy, Enemies }
enum AttackRange { Melee, Ranged }

@export
var Name : String = "Hit"
@export
var animation: PackedScene
@export
var Element : ElementalType:
	get:
		if(_e == null):
			return ElementManager.Blank
		return _e
	
	set(value): _e = value

var _e: ElementalType = ElementManager.Blank
@export
var Priority : int = 0
@export
var ARange: AttackRange = AttackRange.Melee
@export
var Target : TargetType = TargetType.Enemy
@export_multiline
var Details : String 

# virtual
func PlayAnimation(start: Vector2, end: Vector2) -> Node:
	var obj = animation.Instantiate()
	obj.Call("_play", start, end, Element)
	return obj

# virtual
func IsActionAvailable(actor: BattleActor) -> bool:
	return true

# Main logic for action.
# Returns message stating what happened to the targets. This is displayed for player.
func ApplyEffects(user: BattleActor, targets) -> String:
	var end = ""
	if len(targets) == 1:
		if user == targets[0]:
			end = "itself"
		else:
			end =  targets[0].ActorName
	else:
		end = "the opposing team"

	return "%s used %s on %s." % [ user.ActorName, Name, end ]

func ApplyCost(user: BattleActor) -> void: 
	pass
