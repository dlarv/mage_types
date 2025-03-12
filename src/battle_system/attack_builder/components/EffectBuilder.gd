@tool
extends VBoxContainer

signal effect_created(effect: EffectSlot)

@export var attack_effects: Array[AttackEffect]
@export var stats: Array[StatChange]
@export var effect_option_button: OptionButton
@export var stat_option_button: OptionButton
@export var stat_hbox: HBoxContainer

var _effect: EffectSlot

func _enter_tree():
	_effect = EffectSlot.new()
	_effect.attack_effect = attack_effects[0]

	for effect in attack_effects:
		effect_option_button.add_item(effect.name)
	
	for stat in stats:
		stat_option_button.add_item(stat.name)

func _on_effect_item_selected(index:int) -> void:
	var e := attack_effects[index]
	var attack_effect: AttackEffect

	_effect = EffectSlot.new()

	if e is StatChange:
		stat_hbox.show()
		_effect.attack_effect = stats[0]
	else:
		stat_hbox.hide()
		_effect.attack_effect = e


func _on_create_button_pressed() -> void:
	effect_created.emit(_effect)

	effect_option_button.select(0)
	_on_effect_item_selected(0)


func _on_stat_item_selected(index:int) -> void:
	_effect.attack_effect = stats[index]

