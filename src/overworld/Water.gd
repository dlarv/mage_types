@tool
extends Area3D
class_name Water

func _enter_tree() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	collision_mask = 64
	collision_layer = 0
	

func _on_body_entered(body: Node3D) -> void:
	if body is Water: return
	if body.has_method("jump_to_last_stable_position"):
		body.jump_to_last_stable_position()
