extends Area3D

@export var other_side: Area3D
var in_cooldown := false

func _on_body_entered(node: Node3D) -> void:
	if not in_cooldown and node.is_in_group("player"):
		other_side.start_cooldown()
		node.global_position = other_side.global_position

func start_cooldown() -> void:
	in_cooldown = true


func _on_body_exited(body:Node3D) -> void:
	in_cooldown = false

