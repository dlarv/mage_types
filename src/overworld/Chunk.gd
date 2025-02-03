extends Area3D

@export var chunk: Node3D

func _enter_tree() -> void:
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
	body_entered.connect(load)
	body_exited.connect(unload)


func load(player: Node3D) -> void:
	if not player.is_in_group("player"): return
	chunk.process_mode = Node.PROCESS_MODE_INHERIT

func unload(player: Node3D) -> void:
	if not player.is_in_group("player"): return
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
