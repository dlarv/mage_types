extends AttackAnimation

func superimpose(user: CanvasItem, target: CanvasItem, is_flipped: bool):
	position.x += user.get_size().x / 2
	position.y += user.get_size().y / 2

	if is_flipped:
		rotation = deg_to_rad(180)
	user.add_child(self)

