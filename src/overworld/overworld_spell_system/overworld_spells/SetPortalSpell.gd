extends OverworldSpell

signal portal_position_set(pos: Vector3)

var _player: Node3D

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")


# Override 
func perform_action() -> void: 
	portal_position_set.emit(_player.global_position)
