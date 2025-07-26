extends Node3D

@export var player: Node3D 
@export var companions: Array[Node3D]

@export var player_menu: Control 
@export var inventory: Node

func _ready() -> void:
	var actors: Array[BattleActor] = [player.battle_actor]

	for companion in companions:
		actors.append(companion.battle_actor)

	player.party = actors

	player_menu.init_inventory(inventory)
	player.inventory = inventory
