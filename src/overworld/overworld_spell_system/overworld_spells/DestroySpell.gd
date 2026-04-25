extends OverworldSpell

# Override 
func perform_action() -> void: 
	_spawn_projectile(collision_test, action_to_perform, _channel_element())


func action_to_perform(body: Node3D, element: ElementalType) -> void:
	if element.is_defensive_type != body.element.is_defensive_type:
		body.destroy()


