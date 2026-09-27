@tool
extends Node3D

signal pin_selected(effect: StatusEffect)
signal pin_hovered(pin: Node3D)
signal pin_unhovered(pin: Node3D)

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")
const Effect := StatusEffectManager.StatusEffects
const INSERTION_PIN := preload("res://assets/audio/battle_system/pin_insert.ogg")

@export var status_effect: Effect = Effect.PHOBIC:
	set(val):
		status_effect = val
		if val == Effect.PHOBIC:
			_effect_name = "%s-Phobic" % element.name
		else:
			_effect_name = str(Effect.keys()[status_effect]).capitalize()

		element = map_status_to_element(val, name)
		_show_head(val)


var element: ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 

		if _mat != null:
			_mat.albedo_color = element.main_color

		_show_head(status_effect)


var _effect: StatusEffect
var _mat: StandardMaterial3D
var _effect_name: String:
	set(val):
		_effect_name = val
		if len(%Area3D.tooltip_strings) == 0:
			%Area3D.tooltip_strings = [""] as Array[String]
		%Area3D.tooltip_strings[0] = _effect_name
var _is_wiggling := false

var _activation_sfx: AudioStream

func _enter_tree() -> void:
	element = map_status_to_element(status_effect, name)
	_activation_sfx = map_status_to_audio_stream(status_effect)

	# Set color
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = element.main_color
	%status_pin/Cube.set_surface_override_material(1, _mat)
	%status_pin/Cube/PhobiaHead.set_surface_override_material(0, _mat)

	# Set tooltip
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
			pin_selected.emit(_effect)


func _on_mouse_exited() -> void:
	pin_unhovered.emit(self)


func _on_mouse_entered() -> void:
	pin_hovered.emit(self)


func insert(effect: StatusEffect) -> void:
	show()
	self._effect = effect
	%status_pin/AnimationPlayer.play("insert")
	_play_stream(INSERTION_PIN)


func set_duration(duration: int) -> void:
	%Area3D.tooltip_strings[0] = "%s (%d turns)" % [ _effect_name, duration ]


func activate() -> void:
	_is_wiggling = true
	%status_pin/AnimationPlayer.play("wiggle")
	_play_stream(_activation_sfx)
	await %status_pin/AnimationPlayer.animation_finished
	_is_wiggling = false


func remove() -> void: 
	while _is_wiggling:
		await get_tree().create_timer(0.01).timeout
	hide()


func _play_stream(sfx: AudioStream) -> void:
	if sfx == null: return
	if %AudioStreamPlayer.playing:
		# Activation sfx will override insertion sfx, but not vice versa
		if %AudioStreamPlayer.stream == _activation_sfx: 
			return
		elif %AudioStreamPlayer != sfx: 
			%AudioStreamPlayer.stop()

	%AudioStreamPlayer.stream = sfx
	%AudioStreamPlayer.play()


static func map_status_to_element(status: StatusEffect.Effects, name: String="") -> ElementalType:
	const SE := StatusEffect.Effects
	match status:
		SE.STASIS: return ElementManager.Blue
		SE.BLOCK: return ElementManager.Cyan
		SE.POISON: return ElementManager.Green
		SE.HEALING: return ElementManager.Magenta
		SE.FLINCH: return ElementManager.Purple
		SE.PHOBIC:
			for el in ElementManager.elements:
				if el.name.to_lower() in name.to_lower():
					return el
	return ElementManager.Blank


static func map_status_to_audio_stream(status: StatusEffect.Effects) -> AudioStream:
	const SE := StatusEffect.Effects
	const PATH := "res://assets/audio/battle_system"
	match status:
		SE.STASIS: return load("%s/%s" % [PATH, "stasis.ogg"])
		SE.POISON: return load("%s/%s" % [PATH, "poison.ogg"])
		SE.BLOCK: return load("%s/%s" % [PATH, "block.ogg"])
		SE.HEALING: return load("%s/%s" % [PATH, "healing.ogg"])
		SE.FLINCH: return load("%s/%s" % [PATH, "flinch.ogg"])
		SE.PHOBIC: return load("%s/%s" % [PATH, "phobia.ogg"])
	return null
