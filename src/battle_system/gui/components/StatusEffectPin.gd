@tool
extends Node3D

signal pin_selected(effect: StatusEffect)

@export_enum("Stasis", "Healing", "Poison", "Blocking", "Phobic")
var status_effect: String = "Phobic":
	set(val):
		status_effect = val
		_show_head(val)

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 
		if _phobic_mat != null:
			_phobic_mat.albedo_color = element.main_color

var _phobic_mat: StandardMaterial3D

var effect: StatusEffect

func _enter_tree() -> void:
	_phobic_mat = StandardMaterial3D.new()
	_phobic_mat.albedo_color = element.main_color
	$status_pin/Cube.set_surface_override_material(1, _phobic_mat)

func _show_head(effect: String) -> void:
	for head in $status_pin/Cube.get_children():
		if head.name == "%sHead" % effect:
			head.show()
		else:
			head.hide()


func _on_input_event(camera:Node, event:InputEvent, event_position:Vector3, normal:Vector3, shape_idx:int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
			pin_selected.emit(effect)

func _on_mouse_exited() -> void:
	pass # Replace with function body.

func _on_mouse_entered() -> void:
	pass # Replace with function body.

func insert(effect: StatusEffect) -> void:
	self.effect = effect
	$status_pin/AnimationPlayer.play("insert")

func remove() -> void:
	pass
