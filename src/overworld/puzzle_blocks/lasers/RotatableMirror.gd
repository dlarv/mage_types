@tool
extends "Mirror.gd"

func _on_interactable_interacted(obj:Node3D) -> void:
	if not _active_receiver: 
		rotation_degrees.y += 90
		return
	block(true)
	await get_tree().create_timer(0.2).timeout
	rotation_degrees.y += 90
	block(false)
