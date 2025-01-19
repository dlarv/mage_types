extends RigidBody3D

@export var max_bounces := 0
@export var speed := 30.0

# func(Node3D)
var action_to_perform: Callable
# func(Node3D)
var collision_test: Callable

var element: ElementalType

func _enter_tree() -> void:
	get_tree().create_timer(5).timeout.connect(func(): queue_free())

func setup(collision_test: Callable, action_to_perform: Callable, element: ElementalType, forward: Vector3) -> void:
	self.collision_test = collision_test
	self.action_to_perform = action_to_perform
	self.element = element

	var mat := StandardMaterial3D.new()
	mat.albedo_color = element.main_color
	$MeshInstance3D.set_surface_override_material(0, mat)

	linear_velocity = forward * speed

func _on_body_entered(body:Node) -> void:
	if collision_test.call(body):
		action_to_perform.call(body, element)
	
	if max_bounces == 0:
		queue_free()
	max_bounces -= 1
	
