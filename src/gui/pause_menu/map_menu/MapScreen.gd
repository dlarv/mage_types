extends Control

const PAN_INCREMENT := 0.8
const ZOOM_INCREMENT := 0.08
const MAX_ZOOM_LEVEL := 10.0
const MIN_ZOOM_LEVEL := -5.0

@export var current_zoom_level := 0.0
var _in_pan_mode := false


func _gui_input(event: InputEvent) -> void:
	# When zooming 
	if event.is_action_pressed("pan_map"):
		_in_pan_mode = true
	elif event.is_action_released("pan_map"):
		_in_pan_mode = false
	elif _in_pan_mode and event is InputEventMouseMotion:
		_pan(event.screen_relative)
		# _handle_input_mouse_motion(event)
	elif event.is_action_pressed("zoom_map_out"):
		_zoom(max(current_zoom_level - ZOOM_INCREMENT, MIN_ZOOM_LEVEL))
	elif event.is_action_pressed("zoom_map_in"):
		_zoom(min(current_zoom_level + ZOOM_INCREMENT, MAX_ZOOM_LEVEL))
	


func _zoom(level: float) -> void:
	current_zoom_level = level

	# Zoom and recenter
	scale = Vector2(1.0 + current_zoom_level, 1.0 + current_zoom_level)


func _pan(delta: Vector2) -> void:
	position += delta * PAN_INCREMENT

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
