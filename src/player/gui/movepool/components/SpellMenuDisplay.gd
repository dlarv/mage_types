extends VBoxContainer

signal spell_selected(spell)
signal canceled()
signal replace_spell_requested()

@export
var hbox: HBoxContainer
@export
var label: InfoDisplay
@export
var replace_button: Button
@export
var learn_button: Button

var _active_spell: Attack = null

func show_info(spell: Attack, replaceSpell: bool):
	_active_spell = spell
	label.display_message_non_blocking(spell)
	hbox.show()
	replace_button.visible = replaceSpell
	learn_button.visible = not replaceSpell

func _on_cancel_button_pressed():
	_active_spell = null
	hbox.hide()
	label.clear_message()
	canceled.emit()

func _on_learn_spell_button_pressed():
	spell_selected.emit(_active_spell)
	_active_spell = null
	hbox.hide()
	label.clear_message()

func _on_replace_spell_button_pressed():
	replace_spell_requested.emit()
	_active_spell = null
	hbox.hide()
	label.clear_message()
