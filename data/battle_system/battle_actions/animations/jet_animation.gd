extends BattleActionAnimation

func _play(start: Vector2i, end: Vector2i, element=null):
	position = start
	look_at(end)
