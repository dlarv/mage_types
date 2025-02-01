@tool
extends Node3D

@export var target: PuzzleBlock
@export var on_color := Color.RED
@export var off_color := Color.DIM_GRAY

var gradient: Gradient

func _ready() -> void:
	if target != null:
		target.on.connect(_on_block_on)
		target.off.connect(_on_block_off)

	gradient = Gradient.new()
	gradient.add_point(0, off_color)
	while gradient.get_point_count() > 1:
		gradient.remove_point(0)

	$Decal.texture_albedo = GradientTexture1D.new()
	$Decal.texture_albedo.gradient = gradient


func _on_block_on(block: PuzzleBlock) -> void:
	gradient.set_color(0, on_color)


func _on_block_off(block: PuzzleBlock) -> void:
	gradient.set_color(0, off_color)
