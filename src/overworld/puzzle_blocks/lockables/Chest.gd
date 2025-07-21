extends Lockable

@export var items: Array[ItemSlot]
@export var _opened_color := Color.BLACK
var _is_opened := false
var _mat: StandardMaterial3D

func _ready() -> void:
	_mat = StandardMaterial3D.new()
	_lock(len(locks) > 0)

	for lock in locks:
		_opened_locks[lock] = false
		lock.on.connect(_on_lock_opened)
		lock.off.connect(_on_lock_closed)


func _on_lock_opened(block: PuzzleBlock) -> bool:
	if _is_opened: return false
	if not super._on_lock_opened(block): return false

	Logger.append_puzzle_log("Chest(%s)'s Lock(%s) was opened." % [puzzle_name, block.puzzle_name])
	_lock(false)
	return true


func _on_lock_closed(block: PuzzleBlock) -> bool:
	if _is_opened: return false
	if not super._on_lock_closed(block): return false

	_lock(true)
	Logger.append_puzzle_log("Chest(%s)'s Lock(%s) was closed." % [puzzle_name, block.puzzle_name])
	return true


func _update_mesh() -> void:
	$chest/Ribbon.hide()
	_mat.albedo_color = _opened_color
	$chest/Box.set_surface_override_material(0, _mat)


func serialize() -> Dictionary:
	return {
		"path": get_path(),
		"opened": _is_opened,
	}


func deserialize(data: Dictionary) -> void:
	if "opened" in data:
		_is_opened = data["opened"]
		if _is_opened:
			_update_mesh()
			$Interactable.set_disabled(_is_opened)


func _lock(val) -> void:
	$Interactable.set_disabled(val)
	if val:
		$chest/Ribbon.show()
	else:
		$chest/Ribbon.hide()


func _on_interactable_interacted(obj:Node3D) -> void:
	if _is_opened: return
	_is_opened = true
	$Interactable.set_disabled(true)
	var msg := "You opened a chest!"
	for item in items:
		msg += "[br]%s (x%d)" % [ item.item.name, item.quantity ]
		Inventory.add(item.item, item.quantity)
	await UIManager.show_dialog(msg)
	_update_mesh()
