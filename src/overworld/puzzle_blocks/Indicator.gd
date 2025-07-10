extends Node3D

@export var block: PuzzleBlock
@export var on_material: StandardMaterial3D
@export var off_material: StandardMaterial3D
@export var invalid_material: StandardMaterial3D

func _ready() -> void:
	if on_material:
		block.on.connect(_on_block_on)
	if off_material:
		block.off.connect(_on_block_off)
	if invalid_material:
		block.invalid_off.connect(_on_block_invalid_off)

	$MeshInstance3D.set_surface_override_material(0, off_material)


func _on_block_on(lock: PuzzleBlock) -> void:
	$MeshInstance3D.set_surface_override_material(0, on_material)


func _on_block_off(lock: PuzzleBlock) -> void:
	$MeshInstance3D.set_surface_override_material(0, off_material)


func _on_block_invalid_off(lock: PuzzleBlock) -> void:
	$MeshInstance3D.set_surface_override_material(0, invalid_material)
