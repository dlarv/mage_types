@tool
extends PuzzleBlock

@export var toggle_mode := false
var _on_color := Color.GREEN
var _off_color := Color.DARK_SLATE_GRAY
var _mat: StandardMaterial3D


func _ready() -> void:
	_mat = StandardMaterial3D.new()
	if not toggle_mode:
		_off_color = Color.WHITE
		_on_color = _off_color
	
	_mat.albedo_color = _on_color if is_on else _off_color
	$MeshInstance3D.set_surface_override_material(0, _mat)


func _on_interactable_interacted(obj: Node3D) -> void:
	is_on = not is_on

	if not toggle_mode or is_on:
		on.emit(self)
		_mat.albedo_color = _on_color
	else:
		off.emit(self)
		_mat.albedo_color = _off_color

