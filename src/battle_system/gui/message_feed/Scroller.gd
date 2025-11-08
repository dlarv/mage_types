extends ScrollContainer

@onready var v_scroll := get_v_scroll_bar()
var auto_scroll := true


func _draw() -> void:
	if auto_scroll:
		scroll_vertical = int(get_v_scroll_bar().max_value)
	else:
		auto_scroll = v_scroll.size.y + scroll_vertical >= v_scroll.max_value


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		auto_scroll = false

