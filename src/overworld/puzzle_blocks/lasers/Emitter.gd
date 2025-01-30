@tool
extends PuzzleBlock

@export var Laser: PackedScene
@export var laser_speed := 10.0

func _physics_process(delta: float) -> void:
	if is_on and $Timer.is_stopped() and not in_stasis:
		var laser := Laser.instantiate()
		laser.linear_velocity = transform.basis.y * laser_speed
		laser.set_element(element)
		add_child(laser)
		$Timer.start()
