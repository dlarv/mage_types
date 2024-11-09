extends RigidBody3D

signal broke(position: Vector3, body: Node3D)

@export var bounces := 1
@export var speed := 40.0


func setup(initialPos: Vector3) -> void:
	var trans := get_global_transform().basis
	apply_central_impulse(-trans.z * speed)


func _on_body_entered(body: Node) -> void:
	bounces -= 1

	var isAlchemic := false
	if body.is_in_group("alchemic"):
		isAlchemic = true

	if bounces == -1: 
		break_projectile(body, isAlchemic)


func break_projectile(body: Node, isAlchemic: bool) -> void:
	if isAlchemic:
		broke.emit(position, body)
	else:
		broke.emit(position, null)

	queue_free()

