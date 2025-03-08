extends PuzzleBlock

@export var locks: Array[PuzzleBlock]
@export var items: Array[ItemSlot]
var is_opened := false

var _opened_locks := {}

func _ready() -> void:
	if len(locks) > 0:
		$Grabbable.set_disabled(true)

	for lock in locks:
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)

func _on_grabbed(obj: Node3D, player: Node3D) -> void:
	if is_opened: return
	is_opened = true
	$Grabbable.set_disabled(true)
	var msg := "You opened a chest!"
	for item in items:
		msg += "[br]%s (x%d)" % [ item.item.name, item.quantity ]
		Inventory.add(item.item, item.quantity)
	await UIManager.show_dialog(msg)
	_update_mesh()

func _on_lock_opened(block: PuzzleBlock) -> void:
	if is_opened: return
	if not _opened_locks.get(block):
		_opened_locks[block] = true
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Chest(%s)'s Lock(%s) was opened." % [puzzle_name, block.puzzle_name])

	for openedLock in _opened_locks.values():
		if not openedLock: return
	$Grabbable.set_disabled(false)

func _on_lock_closed(block: PuzzleBlock) -> void:
	if is_opened: return
	if _opened_locks.get(block):
		_opened_locks[block] = true
		$Grabbable.set_disabled(true)
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Chest(%s)'s Lock(%s) was closed." % [puzzle_name, block.puzzle_name])


func _update_mesh() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.BLACK
	$MeshInstance3D.set_surface_override_material(0, mat)

func serialize() -> Dictionary:
	return {
		"path": get_path(),
		"opened": is_opened,
	}

func deserialize(data: Dictionary) -> void:
	if "opened" in data:
		is_opened = data["opened"]
		if is_opened:
			_update_mesh()
			$Grabbable.set_disabled(is_opened)
