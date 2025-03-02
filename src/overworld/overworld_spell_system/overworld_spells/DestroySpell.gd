extends OverworldSpell

# Override 
func _perform_action() -> void: 
	_spawn_projectile(collision_test, action_to_perform, _channel_element())


func action_to_perform(body: Node3D, element: ElementalType) -> void:
	body.destroy()


func collision_test(body: Variant) -> bool:
	return body is MagiClay
