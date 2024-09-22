extends Node3D 
class_name EnemyActor 

@export
var ai : OpponentController 
@export
var battle_actor : BattleActor 

var team: 
	get: return [ battle_actor ]

