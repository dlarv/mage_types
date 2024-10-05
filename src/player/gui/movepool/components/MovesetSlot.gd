@tool
extends Button

signal show_info_requested(spell)
signal set_spell_requested(slot)

var index: int
var spell: Attack = null


func set_spell(attack: Attack) -> void:
	spell = attack

	if attack == null:
		pressed.connect(_on_empty_slot_pressed)
		return

	text = spell.name

	if pressed.is_connected(_on_empty_slot_pressed):
		pressed.disconnect(_on_empty_slot_pressed)
	if not pressed.is_connected(_on_filled_slot_pressed):
		pressed.connect(_on_filled_slot_pressed)


func clear() -> void:
	spell = null
	text = ""

	if pressed.is_connected(_on_filled_slot_pressed):
		pressed.disconnect(_on_filled_slot_pressed)
	if not pressed.is_connected(_on_empty_slot_pressed):
		pressed.connect(_on_empty_slot_pressed)


func _on_filled_slot_pressed() -> void:
	show_info_requested.emit(spell)

func _on_empty_slot_pressed() -> void:
	set_spell_requested.emit(self)
	clear()
