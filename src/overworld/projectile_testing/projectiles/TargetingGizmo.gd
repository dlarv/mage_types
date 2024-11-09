extends Node3D

@export var GhostProjectile: PackedScene
@export var max_ghosts := 20

@onready var impact_gizmo: MeshInstance3D = $Impact
@onready var raycast: RayCast3D = $RayCast3D
@onready var transmutation_gizmo: MeshInstance3D = $Impact/Deflection/MeshInstance3D

var _ghosts := []
var _mat1: StandardMaterial3D
var _mat2: StandardMaterial3D

func _ready() -> void:
	_mat1 = StandardMaterial3D.new()
	_mat2 = StandardMaterial3D.new()
	impact_gizmo.set_surface_override_material(0, _mat1)
	transmutation_gizmo.set_surface_override_material(0, _mat2)


func trace_spell(element: ElementalType) -> void:
	if len(_ghosts) == 0:
		transmutation_gizmo.hide()
	_mat1.albedo_color = element.main_color
	_mat2.albedo_color = Color.GRAY
	var mousePos := get_viewport().get_mouse_position()

	# Cast ray to find intersection with ground (y=0).
	# Find where a ray intersects with an axis.
	# https://gamedev.stackexchange.com/questions/194616/how-to-raycast-down-to-the-floor-plane-to-determine-world-space-coordinates-in-g
	var cam := get_viewport().get_camera_3d()
	var origin := cam.project_ray_origin(mousePos)
	var end := cam.project_ray_normal(mousePos)
	var distance := -origin.y/end.y
	var pos := origin + end * distance
	pos.y =  raycast.global_position.y

	# Show targeting info.
	raycast.look_at(pos)
	var collision := raycast.get_collision_point()
	impact_gizmo.position = collision
	var obj := raycast.get_collider()
	if obj != null and obj.is_in_group("alchemic"):
		if obj.transmutes_projectile:
			transmutation_gizmo.show()
			var result := ElementManager.get_matchup(obj.element, element)
			if result != null:
				_mat2.albedo_color = result.main_color


	# Spawn ghost projectile.
	if len(_ghosts) == max_ghosts: return
	var projectile := GhostProjectile.instantiate()
	var r2 := impact_gizmo.get_child(0)

	projectile.broke.connect(func(point, body): 
		transmutation_gizmo.show()
		point.y = r2.global_position.y
		# Rotate targeting_gizmo to show player which direction projectile will bounce towards.
		_ghosts.erase(projectile)
		r2.look_at(point))

	# Add ghost to tree.
	projectile.look_at_from_position(global_position, impact_gizmo.position)
	_ghosts.append(projectile)
	get_tree().get_root().add_child(projectile)
	projectile.setup(global_position)

func get_direction() -> Vector3:
	return impact_gizmo.position

func clear_ghosts() -> void:
	for ghost in _ghosts:
		ghost.queue_free()
	_ghosts = []
	transmutation_gizmo.hide()
	hide()
