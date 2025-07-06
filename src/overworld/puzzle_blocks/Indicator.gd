extends Node3D

@export var block: PuzzleBlock
var _mat: BaseMaterial3D

func _ready() -> void:
	block.on.connect(_on_block_on)
	block.off.connect(_on_block_off)
	block.invalid_off.connect(_on_block_invalid_off)

	_mat = StandardMaterial3D.new()
	_mat.albedo_color = Color.WHITE
	$MeshInstance3D.set_surface_override_material(0, _mat)


func _on_block_on(lock: PuzzleBlock) -> void:
	_mat.albedo_color = Color.GREEN


func _on_block_off(lock: PuzzleBlock) -> void:
	_mat.albedo_color = Color.WHITE


func _on_block_invalid_off(lock: PuzzleBlock) -> void:
	_mat.albedo_color = Color.RED
