extends PuzzleBlock

@export var lock: PuzzleBlock

var _mat: BaseMaterial3D



func _ready() -> void:
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = Color.RED
	$MeshInstance3D.set_surface_override_material(0, _mat)

	if lock:
		lock.off.connect(_on_lock_closed)
		lock.invalid_off.connect(_on_lock_invalid)


func _on_interactable_interacted(obj: Node3D) -> void:
	is_on = not is_on
	if is_on:
		on.emit(self)
		_mat.albedo_color = Color.GREEN
	else:
		_mat.albedo_color = Color.RED
		off.emit(self)


func _on_lock_closed(block: PuzzleBlock) -> void:
	is_on = false
	_mat.albedo_color = Color.RED


func _on_lock_invalid(block: PuzzleBlock) -> void:
	is_on = false
	_mat.albedo_color = Color.RED
