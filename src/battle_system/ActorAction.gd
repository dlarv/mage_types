extends Node
class_name ActorAction 

## Datatype for actions selected by BattleActors.
## These are basically like an instance of a BattleAction.
# public static ActorAction[] Flee = new ActorAction[0];

var actor: BattleActor ;
var priority: int ;
var action: BattleAction ;
# BattleActor[]
var targets = []
var team_index: int

func _init(actor: BattleActor, action: BattleAction, targets, teamIndex: int) -> void:
	self.actor = actor;
	self.action = action;
	self.priority = action.priority;
	self.targets = targets;
	self.team_index = teamIndex;

func compare_to(other: ActorAction) -> int: 
	return 0
	# if other == null:
	# 	return 1;
	# # Compare priority.
	#
	# if(self.priority.CompareTo(other.priority) != 0):
	# 	return self.priority.CompareTo(other.priority);
	# # If both actions have the same priority, compare speeds.
	# if(self.actor.Speed.CompareTo(other.actor.Speed) != 0):
	# 	return self.actor.Speed.CompareTo(other.actor.Speed);
	#
	# var speed1 = self.actor.Speed + GD.RandRange(-5, 5);
	# # If both actors have the same speed stat, randomize.
	# var speed2 = other.actor.Speed + GD.RandRange(-5, 5);
	# return speed1.CompareTo(speed2);
