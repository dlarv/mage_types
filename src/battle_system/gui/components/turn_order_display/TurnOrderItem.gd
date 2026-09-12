extends HBoxContainer


func _init(actorName:="", element: ElementalType=null) -> void:
	var texture_rect := TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(32, 32)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	if element != null:
		texture_rect.texture = element.icon
		texture_rect.modulate = element.main_color
	add_child(texture_rect)

	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = actorName
	add_child(label)

