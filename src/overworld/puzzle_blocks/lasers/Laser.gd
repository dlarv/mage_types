@tool
extends MagiClay

@export var Disruption: PackedScene
@export var lifetime := 8.0
@export var laser_speed := 8.0
var rand_val: int

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return

	var tex = $Decal.texture_albedo.duplicate()
	var grad = $Decal.texture_albedo.gradient.duplicate()
	tex.gradient = grad  
	$Decal.texture_albedo = tex

func setup(pos: Vector3, direction: Vector3, e: ElementalType, randVal: int) -> void:
	position = pos
	self.linear_velocity = direction * laser_speed
	set_element(e)
	rand_val = randVal

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		queue_free()

	elif body.get_collision_layer_value(5):
		# If body has rand_val attribute, it is another Laser projectile. 
		if "rand_val" in body:
			if rand_val != body.rand_val:
				var obj := Disruption.instantiate()
				obj.position = position
				get_parent().add_child(obj)
		# Otherwise, collided with a mirror.
		queue_free()

	elif not body.get_collision_layer_value(4): 
		if "element" in body:
			body.set_element(ElementManager.get_matchup(body.element, element), rand_val)
		queue_free()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	lifetime -= delta

	if lifetime <= 0:
		queue_free()


#Override
func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	element = e
	var mat = StandardMaterial3D.new()
	mat.albedo_color = e.main_color
	# $MeshInstance3D.set_surface_override_material(0, mat)
	$Decal.texture_albedo.gradient.set_color(0, element.main_color)
	return true

#Override
func _get_mesh() -> MeshInstance3D:
	# return null
	return $MeshInstance3D
