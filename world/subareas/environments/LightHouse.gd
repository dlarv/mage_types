extends SpotLight3D

@export var speed := 10.0

func _physics_process(delta: float) -> void:
	rotation.y += speed * delta
