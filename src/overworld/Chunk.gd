extends Area3D
class_name Chunk

@export var chunk: Node3D
@export var resets: Array[Node3D]
## Should be set in parent scene. 
## This value is passed to any animation_actors in scene that do not have their own.
@export var animation_player: AnimationPlayer

var _persistent_objs := {}

func _ready() -> void:
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
	body_entered.connect(load)
	body_exited.connect(unload)
	collision_mask = 32
				
	# if len(resets) == 0: return
	if len(resets) == 1:
		var reset := resets[0]
		for child in find_children("", "MagiClay"):
			reset.magiclay_reset.connect(child.reset)
	else:
		for reset in resets:
			for child in reset.get_parent().find_children("", "MagiClay", true):
				reset.magiclay_reset.connect(child.reset)

	# BFS on all children
	var children := chunk.get_children()
	while len(children) > 0:
		var child = children.pop_back()

		if is_in_group("persist"): 
			if child.has_method("serialize"):
				_persistent_objs[child.get_path()] = child
				if child.is_in_group("persist"):
					child.remove_from_group("persist")
					push_warning("Node(%s) is in persist group but is also child of persistent Chunk(%s)" 
							% [ child.puzzle_name, name])

		# Set value for animation_actors w/o their own players.
		# Typically, there will be 1 animation player in the main scene which everything shares.
		# This way, it can access other chunks and characters.
		if animation_player and child is AnimationActor and not child.animation_player:
			child.animation_player = animation_player

		children.append_array(child.get_children())

func load(player: Node3D) -> void:
	# if not player.is_in_group("player"): return
	Logger.append_world_log("Player loaded Chunk(%s)" % name) 
	print("Player loaded Chunk(%s)" % name)
	chunk.process_mode = Node.PROCESS_MODE_INHERIT

func unload(player: Node3D) -> void:
	# if not player.is_in_group("player"): return
	Logger.append_world_log("Player unloaded Chunk(%s)" % name) 
	print("Player unloaded Chunk(%s)" % name)
	chunk.process_mode = Node.PROCESS_MODE_DISABLED

func serialize() -> Dictionary:
	var data := {
		"path": get_path(),
	}

	for key in _persistent_objs.keys():
		data[key] = _persistent_objs[key].serialize()

	return data

func deserialize(data: Dictionary) -> void:
	if not is_node_ready():
		await ready
	for key in data.keys():
		if key is String and key == "path": continue
		_persistent_objs[key].deserialize(data[key])
