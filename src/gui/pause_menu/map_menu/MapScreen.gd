extends Control

const MapIcon := preload("res://src/gui/pause_menu/map_menu/map_icon.tscn")
const MAP_UNIT := 40.0
const PAN_INCREMENT := 0.8
const ZOOM_INCREMENT := 0.08
const MAX_ZOOM_LEVEL := 10.0
const MIN_ZOOM_LEVEL := -5.0

var _current_zoom_level := 0.0
var _in_pan_mode := false
var _icons := []


func _gui_input(event: InputEvent) -> void:
	# When zooming 
	if event.is_action_pressed("pan_map"):
		_in_pan_mode = true
	elif event.is_action_released("pan_map"):
		_in_pan_mode = false
	if _in_pan_mode and event is InputEventMouseMotion:
		_pan(event.screen_relative)
		# _handle_input_mouse_motion(event)
	elif event.is_action_pressed("zoom_map_out"):
		_zoom(max(_current_zoom_level - ZOOM_INCREMENT, MIN_ZOOM_LEVEL))
	elif event.is_action_pressed("zoom_map_in"):
		_zoom(min(_current_zoom_level + ZOOM_INCREMENT, MAX_ZOOM_LEVEL))
	elif event.is_action_pressed("place_map_icon"):
		_place_icon(event.position)
	

func _zoom(level: float) -> void:
	_current_zoom_level = level

	# Zoom and recenter
	scale = Vector2(1.0 + _current_zoom_level, 1.0 + _current_zoom_level)


func _pan(delta: Vector2) -> void:
	position += delta * PAN_INCREMENT


func _place_icon(pos: Vector2) -> void:
	if not is_node_ready():
		await ready

	var icon := MapIcon.instantiate() 
	add_child(icon)
	icon.size = Vector2(MAP_UNIT, MAP_UNIT)
	icon.position = Vector2(pos.x - MAP_UNIT / 2,  pos.y - MAP_UNIT / 2)
	_icons.append(icon)
	icon.pressed.connect(_remove_icon.bind(icon))


func _remove_icon(icon: Button) -> void:
	_icons.remove_at(_icons.find(icon))
	remove_child(icon)
	icon.pressed.disconnect(_remove_icon)


func serialize() -> Dictionary:
	var icons := []
	for icon in _icons:
		icons.append(icon.position)

	return {
		"icons": icons
	}


func deserialize(data: Dictionary) -> void:
	for icon in data.icons:
		_place_icon(icon)


# Doesn't work in wayland
# Code taken from: https://www.exodrifter.space/notes/godot-input-wrap-cursor
# func _handle_input_mouse_motion(event: InputEventMouseMotion) -> void:
# 	var window := Rect2i(
# 		DisplayServer.window_get_position(),
# 		DisplayServer.window_get_size()
# 	)
# 	var new_position := DisplayServer.mouse_get_position()
#
# 	const margin := 10
# 	var warp := false
# 	if new_position.x < window.position.x + margin:
# 		warp = true
# 		new_position.x += window.size.x - (margin * 2)
# 	elif new_position.x > window.end.x - margin:
# 		warp = true
# 		new_position.x -= window.size.x - (margin * 2)
# 	elif new_position.y < window.position.y + margin:
# 		warp = true
# 		new_position.y += window.size.y - (margin * 2)
# 	elif new_position.y > window.end.y - margin:
# 		warp = true
# 		new_position.y -= window.size.y - (margin * 2)
# 	if warp:
# 		DisplayServer.warp_mouse(new_position - window.position)
