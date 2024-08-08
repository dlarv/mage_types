extends Node

@export var battle_actors: Array[BattleActor]

func _ready():
	print("here")
	

func get_battle_actor(id):
	if id is int:
		return null
		#return battle_actors[id]
	
