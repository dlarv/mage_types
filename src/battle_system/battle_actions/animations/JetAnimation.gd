extends BattleActionAnimation

func _play(start: Vector2i, end: Vector2i, parent: Node2D, element=null) -> BattleActionAnimation:
	position = start
	look_at(end)
	parent.add_child(self)
	return self
