extends GPUParticles3D

const DEFAULT_PARTICLE_AMOUNT := 20

var is_ally := false
var _particle_mat: StandardMaterial3D
var _element: ElementalType
var _is_channeling := false

func _ready() -> void:
	_particle_mat = StandardMaterial3D.new()
	draw_pass_1 = BoxMesh.new()
	draw_pass_1.size = Vector3(0.1, 0.1, 0.1)
	draw_pass_1.material = _particle_mat


func set_action_element(e: ElementalType) -> void:
	while _is_channeling: await get_tree().create_timer(0.01).timeout

	_particle_mat.albedo_color = e.main_color
	_element = e


func play_channeling(duration: float, strength: float) -> void:
	_is_channeling = true
	emitting = true
	amount = int(strength * DEFAULT_PARTICLE_AMOUNT * 2)
	await get_tree().create_timer(duration).timeout
	emitting = false
	amount = DEFAULT_PARTICLE_AMOUNT
	_is_channeling = false
