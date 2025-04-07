@tool
extends PanelContainer

signal delete_button_pressed()

@export var name_label: Label
@export var chance: SpinBox 
@export var target: OptionButton 

@export var strength_int: SpinBox
@export var strength_float: SpinBox
@export var element_dropdown: OptionButton
@export var allow_overflow: CheckBox
@export var element_id: CheckButton
@export var heal_percent: SpinBox
@export var min_int: SpinBox
@export var max_int: SpinBox
@export var min_float: SpinBox
@export var max_float: SpinBox

var _effect: EffectSlot

func create(effect: EffectSlot):
	_effect = effect
	var e := effect.attack_effect

	name_label.text = e.name
	chance.value = effect.chance

	if e is Damage:
		strength_int.show()
		strength_int.value = e.strength
	elif e is StatChange:
		strength_int.show()
		strength_int.value = e.strength
	elif e is StatusHeal:
		pass
	elif e is ElementalEffect:
		element_dropdown.show()
		element_dropdown.select(ElementManager.get_index_from_name(effect.attack_effect.element.name))
	elif e is TransmutateAttackEffect:
		element_id.show()
		element_id.set_pressed_no_signal(e.element_id)
	elif e is RandomPhobia:
		min_int.show()
		max_int.show()
		min_int.value = e.min_count
		max_int.value = e.max_count
	elif e is DrainingDamage:
		strength_int.show()
		heal_percent.show()
		strength_int.value = e.strength
		heal_percent.value = e.heal_percent
	elif e is InstantHealthChange:
		strength_int.show()
		allow_overflow.show()
		strength_int.value = e.strength
		allow_overflow.set_pressed_no_signal(e.allow_overflow)

func get_effect() -> EffectSlot:
	return _effect

func _on_delete_button_pressed():
	delete_button_pressed.emit()


func _on_strike_type_item_selected(index:int) -> void:
	_effect.attack_effect.type = index


func _on_max_value_changed(value:float) -> void:
	_effect.attack_effect.max_count = int(value)


func _on_min_value_changed(value:float) -> void:
	_effect.attack_effect.min_count = int(value)


func _on_heal_percent_value_changed(value:float) -> void:
	_effect.attack_effect.heal_percent = value


func _on_element_id_toggled(toggled_on:bool) -> void:
	_effect.attack_effect.element_id = int(toggled_on)


func _on_stack_value_changed(value:float) -> void:
	_effect.attack_effect.stack = int(value)


func _on_allow_overflow_toggled(toggledOn:bool) -> void:
	_effect.attack_effect.allow_overflow = toggledOn


func _on_element_dropdown_item_selected(index:int) -> void:
	_effect.attack_effect.element = ElementManager.elements[index]


func _on_strength_value_changed(value:float) -> void:
	_effect.attack_effect.strength = value
