@tool
extends VBoxContainer

signal effect_created(effect: EffectSlot)

@export var attack_effects: Array[_AttackEffect]
@export var stats: Array[StatManager.Stats]
@export var status_effects: Array[StatusEffect]
@export var effect_option_button: OptionButton
@export var stat_option_button: OptionButton
@export var stat_hbox: HBoxContainer
@export var status_heal_hbox: HBoxContainer
@export var status_heal_option_button: OptionButton

var _effect: EffectSlot

func _enter_tree() -> void:
	_effect = EffectSlot.new()
	_effect.attack_effect = attack_effects[0]

	effect_option_button.clear()
	for effect in attack_effects:
		effect_option_button.add_item(effect.name)
	
	stat_option_button.clear()
	for stat in stats:
		stat_option_button.add_item(StatManager.Stats.keys()[stat])
	
	status_heal_option_button.clear()
	for effect in status_effects:
		status_heal_option_button.add_item(effect.name)


func _on_effect_item_selected(index:int) -> void:
	var e := attack_effects[index]
	var attack_effect: _AttackEffect

	_effect = EffectSlot.new()

	if e is StatChange:
		stat_hbox.show()
		var statChange := StatChange.new()
		statChange.stat = stats[index]
		_effect.attack_effect = statChange
	elif e is StatusHeal:
		status_heal_hbox.show()
		var heal := StatusHeal.new()
		heal.effect = status_effects[0]
		_effect.attack_effect = heal
	else:
		stat_hbox.hide()
		_effect.attack_effect = e


func _on_create_button_pressed() -> void:
	effect_created.emit(_effect)

	effect_option_button.select(0)
	_on_effect_item_selected(0)


func _on_stat_item_selected(index:int) -> void:
	var statChange := StatChange.new()
	statChange.stat = stats[index]
	_effect.attack_effect = statChange


func _on_status_heal_item_selected(index: int) -> void:
	var heal := StatusHeal.new()
	heal.effect = status_effects[index]
	_effect.attack_effect = heal

