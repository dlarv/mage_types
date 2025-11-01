extends Node3D

signal pin_selected(effect: StatusEffect)
signal pin_hovered(effect: Effects, element: ElementalType)

const StatusEffectManager := preload("res://src/battle_system/StatusEffectManager.gd")
const Effects := StatusEffectManager.StatusEffects

var pins: Dictionary[String, Node]= {}
var status_manager: StatusEffectManager

var _active_pin: Node3D

func _ready() -> void:
	pins = {
		"Poison": $PoisonPin,
		"Healing": $HealingPin,
		"Stasis": $StasisPin,
		"Blocking": $BlockingPin,
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
		pin.show()


func remove_pins(effects: Array[StatusEffect]) -> void:
	for effect in effects:
		var key := effect.name
		if effect.id == Effects.PHOBIC:
			key = "%sPhobic" % effect.element

		var pin: Node = pins.get(key)
		if pin != null:
			pin.remove()
			pin.hide()


func _on_pin_selected(effect:StatusEffect) -> void:
	pin_selected.emit(effect)


func _on_pin_hovered(pin: Node3D) -> void:
	pin_hovered.emit(pin.effect, pin.element)
	_active_pin = pin
	pin.set_duration(status_manager.get_status(pin.effect).duration)


func _on_pin_unhovered(pin: Node3D) -> void:
	_active_pin = null
