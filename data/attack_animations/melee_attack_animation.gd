extends AttackAnimation

func superimpose(user: CanvasItem, target: CanvasItem, is_flipped: bool):
	position.x += target.get_size().x / 2
	position.y += target.get_size().y / 2
	target.add_child(self)
