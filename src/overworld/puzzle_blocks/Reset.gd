extends StaticBody3D

signal magiclay_reset()

@export var reset_positions_of: Array[MagiClay]
var _positions := []

func _ready() -> void:
	for obj in reset_positions_of:
		_positions.append(obj.global_position)


func _on_interactable_interacted(obj:Node3D) -> void:
	magiclay_reset.emit()
	
	for i in range(len(_positions)):
		reset_positions_of[i].global_position = _positions[i]
