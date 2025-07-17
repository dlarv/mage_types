extends Control

signal popup_item_selected(element: ElementalType)

const MapIcon := preload("res://src/gui/pause_menu/map_menu/MapIcon.gd")
const MAP_UNIT := 40.0
const PAN_INCREMENT := 0.8
const ZOOM_INCREMENT := 0.08
const MAX_ZOOM_LEVEL := 10.0
const MIN_ZOOM_LEVEL := -5.0

var _current_zoom_level := 0.0
var _in_pan_mode := false
var _icons := []


func _ready() -> void:
	var popupVBox: VBoxContainer = $PopupPanel.get_child(0)

	var i := -1
	for button: Button in popupVBox.get_child(0).get_children():
		i += 1
		button.pressed.connect(func():
			var index := i
			popup_item_selected.emit(ElementManager.elements[index])
			$PopupPanel.hide())
		

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
		_select_icon_to_place(event.position)
	

func _zoom(level: float) -> void:
	_current_zoom_level = level

	# Zoom and recenter
	scale = Vector2(1.0 + _current_zoom_level, 1.0 + _current_zoom_level)


func _pan(delta: Vector2) -> void:
	position += delta * PAN_INCREMENT


func _select_icon_to_place(pos: Vector2) -> void:
	var mousePos := get_viewport().get_mouse_position()
	$PopupPanel.position = mousePos
	$PopupPanel.show()
	var element: ElementalType = await popup_item_selected
	if element == null: return
	var icon := MapIcon.new(MapIcon.MapIconShape.SQUARE, element, MAP_UNIT) 
	icon.set_deferred("position", Vector2(pos.x - MAP_UNIT / 2,  pos.y - MAP_UNIT / 2))
	_place_icon(icon)


func _place_icon(icon: MapIcon) -> void:
	_icons.append(icon)
	icon.removed.connect(_remove_icon)
	add_child(icon)


func _remove_icon(icon: MapIcon) -> void:
	_icons.remove_at(_icons.find(icon))
	remove_child(icon)


func serialize() -> Dictionary:
	var icons := []
	for icon in _icons:
		icons.append(icon.serialize())

	return {
		"icons": icons
	}


func deserialize(data: Dictionary) -> void:
	for icon in get_children():
		if icon is MapIcon:
			_remove_icon(icon)

	_icons = []
	for d in data.icons:
		var output: MapIcon = MapIcon.new(d.shape, d.color, d.size)
		output.set_deferred("position", d.position)
		_place_icon(output)


# Doesn't work in wayland
# Code taken from: https://www.exodrifter.space/notes/godot-input-wrap-cursor
# func _handle_input_mouse_motion(event: InputEventMouseMotion) -> void:
# 	# pass FUNCTION BODY REMOVED FOR BREVITY


func _on_popup_panel_popup_hide() -> void:
	popup_item_selected.emit(null)
