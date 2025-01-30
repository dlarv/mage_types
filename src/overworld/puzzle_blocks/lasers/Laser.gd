@tool
extends MagiClay

var _life := 5.0

func _on_body_entered(body: Node3D) -> void:
	if not body is MagiClay: return
	if not body.get_collision_layer_value(4): 
		queue_free()
		return
	_life = 5.0

	var x: float = abs(self.linear_velocity.x)
	var z: float = abs(self.linear_velocity.z)

	if x > z:
		self.linear_velocity.z = 0
	elif z > x:
		self.linear_velocity.x = 0



#Override
func set_element(e: ElementalType) -> bool:
	element = e
	($Decal.texture_albedo as GradientTexture1D).gradient.set_color(0, element.main_color)
	return true

#Override
func _get_mesh() -> MeshInstance3D:
	return null
