extends Chunk
class_name DetachedChunk

var was_initialized := false
var objs := []

func _ready() -> void:
	if not was_initialized:
		gather_objs()
	
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

	var children := objs.duplicate(false)
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

	for obj in objs:
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		obj.hide()
	


func gather_objs() -> void:
	var detachedChunks = get_parent().find_children("", "DetachedChunk")
	# Array[ [DetachedChunk, CollisionShape3D] ]
	var shapes := []
	for chunk in detachedChunks: 
		chunk.was_initialized = true
		chunk.objs = []
		for child in chunk.get_children():
			if child is CollisionShape3D:
				shapes.append([chunk, child])
			else:
				chunk.objs.append(child)

	# This assumes that all DetachedChunks on this layer will have the same `chunk` value.
	var children := chunk.get_children()
	while len(children) > 0:
		var child = children.pop_back()
		
		# If child does not exist in 3d space, it doesn't make sense to check whether it exists within a shape.
		if not child is Node3D: 
			if child.get_child_count() > 0:
				children.append_array(child.get_children())
			continue

		# If child is inside of shape, do not add its children to search array.
		var taken := false
		for shape in shapes:
			if has_point(shape[1].shape, shape[1].global_position, child.global_position):
				shape[0].objs.append(child)
				taken = true
				break

		if not taken and child.get_child_count() > 0:
			children.append_array(child.get_children())

func has_point(shape: Shape3D, center: Vector3, pos: Vector3) -> bool:
	if shape is BoxShape3D:
		var x1: float = center.x - shape.size.x / 2
		var x2: float = center.x + shape.size.x / 2
		var y1: float = center.y - shape.size.y / 2
		var y2: float = center.y + shape.size.y / 2
		var z1: float = center.z - shape.size.z / 2
		var z2: float = center.z + shape.size.z / 2

		return x1 <= pos.x and pos.x <= x2 \
				and y1 <= pos.y and pos.y <= y2 \
				and z1 <= pos.z and pos.z <= z2

	return false 

func load(player: Node3D) -> void:
	Logger.append_world_log("Player loaded Chunk(%s)" % name) 
	for obj in objs:
		obj.process_mode = Node.PROCESS_MODE_INHERIT
		obj.show()

func unload(player: Node3D) -> void:
	# if not player.is_in_group("player"): return
	Logger.append_world_log("Player unloaded Chunk(%s)" % name) 
	for obj in objs:
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		obj.hide()
