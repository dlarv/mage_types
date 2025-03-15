extends StaticBody3D

signal magiclay_reset()


func _on_interactable_interacted(obj:Node3D) -> void:
	magiclay_reset.emit()

