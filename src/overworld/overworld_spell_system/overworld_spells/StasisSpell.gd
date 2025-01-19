extends OverworldSpell

@export var stasis_length: float

# Override 
func _perform_action() -> void: 
	_spawn_projectile(collision_test, action_to_perform, ElementManager.Blank)


func action_to_perform(body: Node3D, element: ElementalType) -> void:
	body.set_stasis(true, stasis_length)

func collision_test(body: Variant) -> bool:
	return body is MagiClay
