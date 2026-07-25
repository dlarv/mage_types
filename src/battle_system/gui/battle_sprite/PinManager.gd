@tool
extends Node3D

signal pin_selected(effect: StatusEffect)
signal pin_hovered(effect: Effects, element: ElementalType)

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")
const Effects := StatusEffectManager.StatusEffects

@export_tool_button("Show Pins")
var show_pins := _toggle_pin_visibility.bind(true)

@export_tool_button("Hide Pins")
var hide_pins := _toggle_pin_visibility.bind(false)

var pins: Dictionary[String, Node]= {}
var status_manager: StatusEffectManager

var _active_pin: Node3D

func _ready() -> void:
	pins = {
		"Poison": $BodyPins/PoisonPin,
		"Healing": $BodyPins/HealingPin,
		"Stasis": $BodyPins/StasisPin,
		"Blocking": $BodyPins/BlockingPin,
		"Flinched": $BodyPins/FlinchPin,
		"BluePhobic": $PhobiaCrown/BluePhobiaPin,
		"PurplePhobic": $PhobiaCrown/PurplePhobiaPin,
		"MagentaPhobic": $PhobiaCrown/MagentaPhobiaPin,
		"RedPhobic": $PhobiaCrown/RedPhobiaPin,
		"OrangePhobic": $PhobiaCrown/OrangePhobiaPin,
		"YellowPhobic": $PhobiaCrown/YellowPhobiaPin,
		"GreenPhobic": $PhobiaCrown/GreenPhobiaPin,
		"CyanPhobic": $PhobiaCrown/CyanPhobiaPin,
	} 



func insert_pin(effect: StatusEffect) -> void:
	var key := effect.name
	if effect.id == Effects.PHOBIC:
		key = "%sPhobic" % effect.element
	
	var pin: Node = pins.get(key)
	if pin:
		pin.insert(effect)


func remove_pins(effects: Array[StatusEffect]) -> void:
	for effect in effects:
		var key := effect.name
		if effect.id == Effects.PHOBIC:
			key = "%sPhobic" % effect.element

		var pin: Node = pins.get(key)
		if pin != null:
			pin.remove()


func _on_pin_selected(effect:StatusEffect) -> void:
	pin_selected.emit(effect)


func _on_pin_hovered(pin: Node3D) -> void:
	pin_hovered.emit(pin.effect, pin.element)
	_active_pin = pin
	var block := status_manager.get_status(pin.effect)
	if not block: return
	pin.set_duration(block.duration)


func _on_pin_unhovered(pin: Node3D) -> void:
	_active_pin = null


func activate_pin(effect: StatusEffect) -> void:
	var key := effect.name
	if effect.id == Effects.PHOBIC:
		key = "%sPhobic" % effect.element
	
	var pin: Node = pins.get(key)
	if pin:
		pin.activate()


func _toggle_pin_visibility(val: bool) -> void:
	for pin in %BodyPins.get_children():
		pin.visible = val
	for pin in %PhobiaCrown.get_children():
		pin.visible = val
