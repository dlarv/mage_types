extends StaticBody3D

@export var lifetime := 0.2:
	set(val):
		lifetime = val
		$Timer.wait_time = lifetime

func _on_timer_timeout() -> void:
	queue_free()

