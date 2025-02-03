extends Area3D

@export var chunk: Node3D
@export var reset: Node3D

func _enter_tree() -> void:
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
	body_entered.connect(load)
	body_exited.connect(unload)

	if reset == null: return
	for child in find_children("", "MagiClay"):
		reset.magiclay_reset.connect(child.reset)


func load(player: Node3D) -> void:
	if not player.is_in_group("player"): return
	chunk.process_mode = Node.PROCESS_MODE_INHERIT

func unload(player: Node3D) -> void:
	if not player.is_in_group("player"): return
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
