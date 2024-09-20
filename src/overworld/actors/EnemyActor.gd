extends Node3D 
class_name EnemyActor 

@export
var Ai : OpponentController 
@export
var BattleActor : BattleActor 
var Team: 
	get: return [ BattleActor ]

