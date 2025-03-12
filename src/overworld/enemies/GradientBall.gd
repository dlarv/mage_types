extends MeshInstance3D

var _gradient: Gradient

func setup(actor: BattleActor) -> void:
	mesh = mesh.duplicate(true)
	_gradient = mesh.material.albedo_texture.gradient
	mesh.material.albedo_texture.gradient = _gradient
	_gradient.set_color(0, actor.element1.main_color)
	_gradient.set_color(1, actor.element2.main_color)

	actor.element_changed.connect(_on_element_changed)

func _on_element_changed(id: int, e: ElementalType) -> void:
	_gradient.set_color(id, e.main_color)
