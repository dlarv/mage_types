extends Node3D

signal pin_selected(effect: StatusEffect)

var pins := {}

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
	if effect.name == StatusEffectManager.PHOBIC_KEY:
		key = "%s%s" % [effect.element.name, StatusEffectManager.PHOBIC_KEY]
	
	var pin = pins.get(key)
	if pin != null:
		pin.insert(effect)
		pin.show()


func remove_pins(effects: Array) -> void:
	for effect in effects:
		var key = effect.name
		if effect.name == StatusEffectManager.PHOBIC_KEY:
			key = "%s%s" % [effect.element, StatusEffectManager.PHOBIC_KEY]

		var pin = pins.get(key)
		if pin != null:
			pin.remove()
			pin.hide()

func _on_pin_selected(effect:StatusEffect) -> void:
	pin_selected.emit(effect)
