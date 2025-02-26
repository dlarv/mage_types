extends MeshInstance3D

func setup(actor: BattleActor) -> void:
	mesh = mesh.duplicate(true)
	var gradient = mesh.material.albedo_texture.gradient
	mesh.material.albedo_texture.gradient = gradient
	gradient.set_color(0, actor.element1.main_color)
	gradient.set_color(1, actor.element2.main_color)
