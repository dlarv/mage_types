@tool
extends Node3D

@export var target: PuzzleBlock
@export var on_color := Color.RED
@export var off_color := Color.DIM_GRAY
@export var wire_thickness := 0.15:
	set(val):
		wire_thickness = val
		var i := 0
		for vertex in $Path/Body.polygon:
			if vertex.x != 0:
				$Path/Body.polygon[i].x = val
			if vertex.y != 0:
				$Path/Body.polygon[i].y = val
			i += 1

var _mat: StandardMaterial3D

func _ready() -> void:
	if not Engine.is_editor_hint() and target != null:
		target.on.connect(_on_block_on)
		target.off.connect(_on_block_off)

	

func _enter_tree() -> void:
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = off_color
	$Head.set_surface_override_material(0, _mat)
	$Path/Body.material = _mat


func _on_block_on(block: PuzzleBlock) -> void:
	_mat.albedo_color = on_color


func _on_block_off(block: PuzzleBlock) -> void:
	_mat.albedo_color = off_color



