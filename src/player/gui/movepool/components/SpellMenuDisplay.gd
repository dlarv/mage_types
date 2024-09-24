extends VBoxContainer

signal spell_selected(spell)
signal canceled()
signal replace_spell_requested()

@export
var hbox: HBoxContainer
@export
var label: RichTextLabel
@export
var replace_button: Button
@export
var learn_button: Button

var _active_spell: Attack = null

func show_info(spell: Attack, replaceSpell: bool):
	_active_spell = spell
	label.text = spell.name
	hbox.show()
	replace_button.visible = replaceSpell
	learn_button.visible = not replaceSpell

func _on_cancel_button_pressed():
	_active_spell = null
	hbox.hide()
	label.text = ""
	canceled.emit()

func _on_learn_spell_button_pressed():
	spell_selected.emit(_active_spell)
	_active_spell = null
	hbox.hide()
	label.text = ""

func _on_replace_spell_button_pressed():
	replace_spell_requested.emit()
	_active_spell = null
	hbox.hide()
	label.text = ""
