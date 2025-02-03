@tool
extends MagiClay

@export var Disruption: PackedScene
@export var lifetime := 8.0
@export var laser_speed := 8.0
var rand_val: int

func _ready() -> void:
	if Engine.is_editor_hint(): return

	var tex = $Decal.texture_albedo.duplicate()
	var grad = $Decal.texture_albedo.gradient.duplicate()
	tex.gradient = grad  
	$Decal.texture_albedo = tex

func setup(pos: Vector3, direction: Vector3, e: ElementalType, randVal: int) -> void:
	position = pos
	self.linear_velocity = direction * laser_speed
	# print(self.linear_velocity)
	set_element(e)
	rand_val = randVal

func _on_body_entered(body: Node3D) -> void:
	if body.get_collision_layer_value(5):
		if "rand_val" in body:
			if rand_val != body.rand_val:
				var obj := Disruption.instantiate()
				obj.position = position
				get_parent().add_child(obj)
		# Collided with a mirror.
		else:
			queue_free()

	if not body.get_collision_layer_value(4): 
		if "element" in body:
			body.set_element(ElementManager.get_matchup(body.element, element), rand_val)
		queue_free()
		return
	if not body is MagiClay: return
	#
	# if body.is_in_group("mirror") and not element.is_blank() and not body.in_stasis:
	# 	var e := ElementManager.get_matchup(element, body.element)
	# 	body.create_log(self, e)
	# 	if e != null:
	# 		set_element(e)
	#
	#
	# lifetime = 5.0
	#
	# var x: float = abs(self.linear_velocity.x)
	# var z: float = abs(self.linear_velocity.z)
	#
	# self.angular_velocity = Vector3.ZERO
	# if x > z:
	# 	self.linear_velocity.z = 0
	# 	rotation_degrees = Vector3(0, 0, 0)
	# elif z > x:
	# 	self.linear_velocity.x = 0
	# 	rotation_degrees = Vector3(90, 0, 0)
	# self.linear_velocity.y = 0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	lifetime -= delta

	if lifetime <= 0:
		queue_free()


#Override
func set_element(e: ElementalType, randVal:=-2) -> bool:
	element = e
	$Decal.texture_albedo.gradient.set_color(0, element.main_color)
	return true

#Override
func _get_mesh() -> MeshInstance3D:
	return null
