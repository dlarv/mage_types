extends OverworldSpell

var _player: Node3D
var _position: Vector3

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_position = _player.global_position


func _unhandled_input(event: InputEvent) -> void:
	if not is_active: return
	if event.is_action_pressed("cast_spell_1"):
		_position = _player.global_position
		$GPUParticles3D.global_position = _position
	elif event.is_action_pressed("cast_spell_2"):
		_player.global_position = _position


func deactivate() -> void: 
	super.deactivate()
	$GPUParticles3D.emitting = false


func activate() -> void: 
	super.activate()
	$GPUParticles3D.emitting = true
