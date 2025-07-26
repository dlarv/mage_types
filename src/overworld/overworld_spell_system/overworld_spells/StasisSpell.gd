extends OverworldSpell

@export var max_stasis_objects := 3
var _stasis_queue: Array[MagiClay] = []

# Override 
func perform_action() -> void: 
	_spawn_projectile(collision_test, action_to_perform, ElementManager.Blank)


func action_to_perform(body: Node3D, element: ElementalType) -> void:
	body.set_stasis()
	body.stasis_ended.connect(_remove_from_queue.bind(body))

	if not body.in_stasis:
		_remove_from_queue(body)
		return

	if len(_stasis_queue) == max_stasis_objects:
		var obj: MagiClay = _stasis_queue.pop_front()
		if obj.in_stasis:
			obj.set_stasis()
	_stasis_queue.append(body)

func collision_test(body: Variant) -> bool:
	return body is MagiClay

func serialize() -> Dictionary:
	var objs := []
	for obj in _stasis_queue:
		objs.append(obj.get_path())

	return {
		"path": get_path(),
		"queue": objs,
	}

func deserialize(data: Dictionary) -> void:
	_stasis_queue = []
	for obj: NodePath in data["queue"]:
		_stasis_queue.append(get_node(obj))

func _remove_from_queue(body: MagiClay) -> void:
	body.stasis_ended.disconnect(_remove_from_queue)
	var index := _stasis_queue.find(body)
	if index != -1:
		_stasis_queue.remove_at(index)
