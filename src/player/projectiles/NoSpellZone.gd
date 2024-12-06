@tool
extends Area3D

func _on_body_exited(body:Node3D) -> void:
	if body is PhysicsPlayer and body.projectile_manager != null:
		body.projectile_manager.disabled = false

func _on_body_entered(body:Node3D) -> void:
	if body is PhysicsPlayer and body.projectile_manager != null:
		body.projectile_manager.disabled = true
	elif body is Projectile:
		body.break_projectile(self)

