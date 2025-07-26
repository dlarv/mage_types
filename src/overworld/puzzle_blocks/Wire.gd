@tool
extends Node3D

@export var target: PuzzleBlock
@export var on_material: StandardMaterial3D
@export var off_material: StandardMaterial3D
@export var invalid_material: StandardMaterial3D
@export var wire_thickness := 0.15:
	set(val):
		wire_thickness = val
		var i := 0
		for vertex: Vector3 in $Path/Body.polygon:
			if vertex.x != 0:
				$Path/Body.polygon[i].x = val
			if vertex.y != 0:
				$Path/Body.polygon[i].y = val
			i += 1


func _ready() -> void:
	if Engine.is_editor_hint() or target == null: return
	if on_material:
		target.on.connect(_on_block_on)
	if off_material:
		target.off.connect(_on_block_off)
	if invalid_material:
		target.invalid_off.connect(_on_block_invalid)
	

func _enter_tree() -> void:
	$Head.set_surface_override_material(0, off_material)
	$Path/Body.material = off_material


func _on_block_on(block: PuzzleBlock) -> void:
	$Head.set_surface_override_material(0, on_material)
	$Path/Body.material = on_material


func _on_block_off(block: PuzzleBlock) -> void:
	$Head.set_surface_override_material(0, off_material)
	$Path/Body.material = off_material


func _on_block_invalid(block: PuzzleBlock) -> void:
	$Head.set_surface_override_material(0, invalid_material)
	$Path/Body.material = invalid_material
