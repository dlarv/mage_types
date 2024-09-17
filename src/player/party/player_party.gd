extends Node3D

@export var player: Node3D 
@export var companions: Array[Node3D]

@export var pause_menu: Control 
@export var inventory: Node

func _ready() -> void:
	var actors = [player.BattleActor]

	for companion in companions:
		actors.append(companion.BattleActor)

	player.Party = actors

	pause_menu.InitInventory(inventory)
	player.Inventory = inventory

