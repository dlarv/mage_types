@tool
extends _WildEnemySensor

#override
func set_size(size: float) -> void:
	get_child(0).shape.radius = size
