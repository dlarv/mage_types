@tool
extends Node3D

signal pin_selected(effect: StatusEffect)
signal pin_hovered(pin: Node3D)
signal pin_unhovered(pin: Node3D)

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")
const Effect := StatusEffectManager.StatusEffects

# @export_enum("Stasis", "Healing", "Poison", "Blocking", "Phobic")
@export var status_effect: Effect = Effect.PHOBIC:
	set(val):
		status_effect = val
		if val == Effect.PHOBIC:
			_effect_name = "%s-Phobic" % element.name
		else:
			_effect_name = str(Effect.keys()[status_effect]).capitalize()

		_show_head(val)


@export var _element := ElementalType.ElementId.BLANK:
	set(value):
		_element = value
		element = ElementManager.elements[int(value)]
var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

		if _mat != null:
			_mat.albedo_color = element.main_color

		_show_head(status_effect)

var effect: StatusEffect

var _mat: StandardMaterial3D
var _effect_name: String:
	set(val):
		_effect_name = val
		if len(%Area3D.tooltip_strings) == 0:
			%Area3D.tooltip_strings = [""] as Array[String]
		%Area3D.tooltip_strings[0] = _effect_name
var _wiggling := false


func _enter_tree() -> void:
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = element.main_color
	%status_pin/Cube.set_surface_override_material(1, _mat)
	%status_pin/Cube/PhobiaHead.set_surface_override_material(0, _mat)


	%Area3D.tooltip_strings = [""] as Array[String]
	if status_effect == Effect.PHOBIC:
		_effect_name = "%s-Phobic" % element.get_bb_code_name()
	else:
		_effect_name = str(Effect.keys()[status_effect]).capitalize()



func _show_head(e: Effect) -> void:
	if e == Effect.PHOBIC: 
		%status_pin/Cube/PhobiaHead.show()
	else:
		%status_pin/Cube/PhobiaHead.hide()


func _on_input_event(camera:Node, event:InputEvent, event_position:Vector3, normal:Vector3, shape_idx:int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
			pin_selected.emit(effect)


func _on_mouse_exited() -> void:
	pin_unhovered.emit(self)


func _on_mouse_entered() -> void:
	pin_hovered.emit(self)


func insert(effect: StatusEffect) -> void:
	show()
	self.effect = effect
	%status_pin/AnimationPlayer.play("insert")

func set_duration(duration: int) -> void:
	%Area3D.tooltip_strings[0] = "%s (%d turns)" % [ _effect_name, duration ]


func activate() -> void:
	_wiggling = true
	%status_pin/AnimationPlayer.play("wiggle")
	await %status_pin/AnimationPlayer.animation_finished
	_wiggling = false


func remove() -> void: 
	while _wiggling:
		await get_tree().create_timer(0.01).timeout
	
	hide()
