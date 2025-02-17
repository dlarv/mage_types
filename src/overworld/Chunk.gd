extends Area3D
class_name Chunk

@export var chunk: Node3D
@export var resets: Array[Node3D]

func _enter_tree() -> void:
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
	body_entered.connect(load)
	body_exited.connect(unload)

	if len(resets) == 0: return
	elif len(resets) == 1:
		var reset := resets[0]
		for child in find_children("", "MagiClay"):
			reset.magiclay_reset.connect(child.reset)
	else:
		for reset in resets:
			for child in reset.get_parent().find_children("", "MagiClay"):
				reset.magiclay_reset.connect(child.reset)



func load(player: Node3D) -> void:
	if not player.is_in_group("player"): return
	chunk.process_mode = Node.PROCESS_MODE_INHERIT

func unload(player: Node3D) -> void:
	if not player.is_in_group("player"): return
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
