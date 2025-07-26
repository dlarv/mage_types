extends Node3D

signal pin_selected(effect: StatusEffect)

var pins: Dictionary[String, Node]= {}

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
	if effect.id == StatusEffectManager.StatusEffects.PHOBIC:
		key = "%sPhobic" % effect.element
	
	var pin: Node = pins.get(key)
	if pin:
		pin.insert(effect)
		pin.show()


func remove_pins(effects: Array[StatusEffect]) -> void:
	for effect in effects:
		var key := effect.name
		if effect.id == StatusEffectManager.StatusEffects.PHOBIC:
			key = "%sPhobic" % effect.element

		var pin: Node = pins.get(key)
		if pin != null:
			pin.remove()
			pin.hide()

func _on_pin_selected(effect:StatusEffect) -> void:
	pin_selected.emit(effect)
