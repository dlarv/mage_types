@tool
extends Resource
class_name Actor

@export var name: String: 
	set(value):
		name = value
		if battle_actor != null: battle_actor.name = value
@export var battle_actor: BattleActor
