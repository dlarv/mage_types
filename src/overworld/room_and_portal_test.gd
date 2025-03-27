extends Node3D


@export var marker: Marker3D
@export var portal: Node3D

func _ready() -> void:
	portal.point_2 = marker

func _process(delta: float) -> void:
	print(Engine.get_frames_per_second())
