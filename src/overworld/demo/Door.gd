extends Area3D

@export var other_side: Area3D
var player: PhysicsPlayer

func _ready() -> void:
	player = get_parent().find_child("Player")


func _on_body_entered(body:Node3D) -> void:
	if body is PhysicsPlayer and other_side != null:
		other_side.move_to()
		if player != null:
			player.set_active(false)
			player.process_mode = Node.PROCESS_MODE_DISABLED

func move_to() -> void:
	if player != null:
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player.set_active(true)

