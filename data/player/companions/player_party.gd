extends Node3D

func _ready() -> void:
	var actors = []
	for child in get_children():
		actors.append(child.BattleActor)
	get_child(0).Party = actors
