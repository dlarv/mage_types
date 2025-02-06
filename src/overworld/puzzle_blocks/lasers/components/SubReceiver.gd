extends Area3D

signal laser_received(laser: Laser, point: Vector3)
signal laser_dropped()

func set_laser(laser: Laser, point: Vector3) -> void:
	laser_received.emit(laser, point)

func clear_laser() -> void:
	laser_dropped.emit()
