extends OverworldSpell

var _player: Node3D
var _position: Vector3

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_position = _player.global_position

	var setter := get_parent().find_child("SetPortalSpell")
	if not setter.portal_position_set.is_connected(_set_portal_position):
		setter.portal_position_set.connect(_set_portal_position)

# Override 
func perform_action() -> void: 
	_player.global_position = _position

func _set_portal_position(pos: Vector3) -> void:
	_position = pos
