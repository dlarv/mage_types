extends GPUParticles3D

const DEFAULT_PARTICLE_AMOUNT := 20

var is_ally := false
var _show_intentions := true
var _particle_mat: StandardMaterial3D
var _element: ElementalType
var _is_channeling := false

func _ready() -> void:
	Battle.selection_phase_started.connect(func() -> void: 
		_show_intentions = Settings.show_opponent_intentions and not is_ally
	)
	Battle.action_phase_started.connect(func() -> void:
		_show_intentions = false
		emitting = false
	)

	_particle_mat = StandardMaterial3D.new()
	draw_pass_1 = BoxMesh.new()
	draw_pass_1.size = Vector3(0.1, 0.1, 0.1)
	draw_pass_1.material = _particle_mat


func set_action_element(e: ElementalType) -> void:
	while _is_channeling: await get_tree().create_timer(0.01).timeout

	_particle_mat.albedo_color = e.main_color
	_element = e

	# If showing intentions, start playing immediately
	# Otherwise, wait for play_channeling()
	emitting = _show_intentions


func play_channeling(duration: float, strength: float) -> void:
	_is_channeling = true
	emitting = true
	amount = int(strength * DEFAULT_PARTICLE_AMOUNT * 2)
	await get_tree().create_timer(duration).timeout
	emitting = false
	amount = DEFAULT_PARTICLE_AMOUNT
	_is_channeling = false
