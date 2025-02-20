extends TextureRect


func _on_gui_input(event:InputEvent) -> void:
	if not event is InputEventMouseMotion: return
	var pos: Vector2i = (event as InputEventMouseMotion).position
	var color: Color = get_viewport().get_texture().get_image().get_pixelv(pos)

	# If pixel is grayish, it isn't part of the actual flowchart.
	if color.r == color.g and color.g == color.b:
		return




