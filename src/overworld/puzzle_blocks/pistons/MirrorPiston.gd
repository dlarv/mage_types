@tool
extends "../Rails.gd"

@export var mirror_rotation := 0.0:
	set(val):
		$Mirror.rotation_degrees.y = val
	get:
		return $Mirror.rotation_degrees.y
@export var cap_offset: Vector3

@export var mirror_element: ElementalType.ElementId:
	set(val):
		mirror_element = val
		$Mirror._element = val

@export_enum("up", "down") var start_position := "up": 
	set(val):
		start_position = val
		# if not is_inside_tree(): return
		if val == "up":
			$Mirror.position = point_a.position
		else:
			$Mirror.position = point_b.position


func _enter_tree() -> void:
	super._enter_tree()
	if Engine.is_editor_hint(): return

	# Removing Cap's parent (Mirror) rotation works better than using global_rotation.
	%CollisionShape3D.rotation_degrees = -rotation_degrees - $Mirror.rotation_degrees
	%CollisionShape3D.position = cap_offset
