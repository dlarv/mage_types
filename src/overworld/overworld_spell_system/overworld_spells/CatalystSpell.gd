extends OverworldSpell

# Override 
func perform_action() -> void: 
	_spawn_projectile(collision_test, action_to_perform, _channel_element())


func action_to_perform(body: Node3D, element: ElementalType) -> void:
	# var res := ElementManager.get_matchup(element, body.element)
	# body.set_element(res)
	body.react(element)


func collision_test(body: Variant) -> bool:
	return body is MagiClay
