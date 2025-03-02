extends Area3D
class_name Chunk

@export var chunk: Node3D
@export var resets: Array[Node3D]

var _persistent_objs := {}

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

func _ready() -> void:
	if not is_in_group("persist"): return
	var children := chunk.get_children()
	while len(children) > 0:
		var child = children.pop_back()
		if child.has_method("serialize"):
			_persistent_objs[child.get_path()] = child
		children.append_array(child.get_children())


func load(player: Node3D) -> void:
	if not player.is_in_group("player"): return
	chunk.process_mode = Node.PROCESS_MODE_INHERIT

func unload(player: Node3D) -> void:
	if not player.is_in_group("player"): return
	chunk.process_mode = Node.PROCESS_MODE_DISABLED

func serialize() -> Dictionary:
	var data := {
		"path": get_path(),
	}

	for key in _persistent_objs.keys():
		data[key] = _persistent_objs[key].serialize()

	return data

func deserialize(data: Dictionary) -> void:
	for key in data.keys():
		if key is String and key == "path": continue

		_persistent_objs[key].deserialize(data[key])
