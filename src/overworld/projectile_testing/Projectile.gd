extends RigidBody3D

@export var bounces := 3
@export var speed := 20.0

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _particles: GPUParticles3D = $GPUParticles3D

var _material: BaseMaterial3D
var _element: ElementalType = ElementManager.Blue:
	set(value):
		_element = value
		var color := value.main_color
		_material = StandardMaterial3D.new()

		_material.albedo_color = color
		if _lower_opacity:
			_material.albedo_color.a = .2


		_mesh_instance.set_surface_override_material(0, _material)
		_particles.draw_pass_1.surface_set_material(0, _material)

var _lower_opacity := false

func setup(initialPos: Vector3, element: ElementalType=null, lowerOpacity:=false) -> void:
	if element == null: 
		element = ElementManager.Blank
	_element = element
	_lower_opacity = lowerOpacity

	position = initialPos
	var trans := get_global_transform().basis
	apply_central_impulse(-trans.z * speed)

	if lowerOpacity:
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material.albedo_color.a = .2


func _on_body_entered(body:Node) -> void:
	bounces -= 1

	if body.is_in_group("alchemic"):
		var reaction = body.transmute(_element)
		if reaction != null:
			_element = reaction

	if bounces == 0: 
		_mesh_instance.hide()
		_particles.emitting = true
		_particles.reparent(body)
		queue_free()
	

