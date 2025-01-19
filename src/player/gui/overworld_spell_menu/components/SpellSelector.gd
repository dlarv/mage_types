@tool
extends HBoxContainer

signal spell_selected(id: OverworldSpell.Spells, isPrimary: bool)

@export var spell: OverworldSpell.Spells:
	set(val):
		var label := find_child("Label")
		if label == null: return
		spell = val
		label.text = str(OverworldSpell.Spells.keys()[val]).capitalize()

func setup(buttonGroup1: ButtonGroup, buttonGroup2: ButtonGroup, isEnabled: bool) -> void:
	$CheckBox1.button_group = buttonGroup1
	$CheckBox2.button_group = buttonGroup2
	visible = isEnabled

	spell_selected.connect(Inventory.select_overworld_spell)

func _on_check_box_1_pressed() -> void:
	spell_selected.emit(spell, true)

func _on_check_box_2_pressed() -> void:
	spell_selected.emit(spell, false)
