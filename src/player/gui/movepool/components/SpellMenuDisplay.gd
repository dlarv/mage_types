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

var _active_scroll: SpellScroll = null

func show_info(scroll, replaceSpell: bool):
	hbox.show()
	replace_button.visible = replaceSpell
	learn_button.visible = not replaceSpell

	if scroll is Attack:
		label.display_message_non_blocking(scroll)
		return

	_active_scroll = scroll
	label.display_message_non_blocking(scroll.spell)

func _on_cancel_button_pressed():
	_active_scroll = null
	hbox.hide()
	label.clear_message()
	canceled.emit()

func _on_learn_spell_button_pressed():
	spell_selected.emit(_active_scroll)
	_active_scroll = null
	hbox.hide()
	label.clear_message()

func _on_replace_spell_button_pressed():
	replace_spell_requested.emit()
	_active_scroll = null
	hbox.hide()
	label.clear_message()
