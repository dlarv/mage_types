extends StaticBody3D

signal magiclay_reset()

func _on_grabbable_grabbed(obj:Node3D, player:Node3D) -> void:
	magiclay_reset.emit()

