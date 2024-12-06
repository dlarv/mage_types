extends RigidBody3D
class_name Projectile

@export var bounces := 3
@export var speed := 20.0

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _particles: GPUParticles3D = $GPUParticles3D

var _material: BaseMaterial3D
var element: ElementalType = ElementManager.Blue:
	set(value):
		element = value
		var color := value.main_color
		_material = StandardMaterial3D.new()

		_material.albedo_color = color

		_mesh_instance.set_surface_override_material(0, _material)
		_particles.draw_pass_1.surface_set_material(0, _material)


func setup(initialPos: Vector3, element: ElementalType=null) -> void:
	if element == null: 
		element = ElementManager.Blank
	self.element = element

	position = initialPos
	var trans := get_global_transform().basis
	apply_central_impulse(-trans.z * speed)


func _on_body_entered(body:Node) -> void:
	bounces -= 1

	if body.is_in_group("alchemic"):
		var state = body.transmute(element)
		if state != null:
			state.apply_changes(self)
		else:
			# ProjectilePrefab is absorbed, unless overwritten in apply_changes()
			bounces = 0


	if bounces == 0: 
		break_projectile(body)


func break_projectile(body) -> void:
	_mesh_instance.hide()
	_particles.emitting = true
	_particles.reparent(body)
	queue_free()
