extends Node3D

@export var player: Node3D 
@export var companions: Array[Node3D]

@export var pause_menu: Control 
@export var inventory: Node

func _ready() -> void:
	var actors = [player.battle_actor]

	for companion in companions:
		actors.append(companion.battle_actor)

	player.party = actors

	pause_menu.init_inventory(inventory)
	player.inventory = inventory
