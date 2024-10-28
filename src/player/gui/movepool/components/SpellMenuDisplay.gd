extends VBoxContainer
class_name SpellMenuDisplay

signal spell_selected(spell)
signal forget_spell_requested()

enum ViewMode { INFO, REPLACE } 

@export var hbox: HBoxContainer
@export var label: InfoDisplay
@export var forget_button: Button
@export var learn_button: Button

var view_mode: ViewMode:
	set(value):
		view_mode = value
		match value:
			ViewMode.INFO:
				forget_button.show()
				learn_button.show()
			ViewMode.REPLACE:
				learn_button.show()
				forget_button.hide()

var _active_scroll: SpellScroll = null:
	set(value):
		_active_scroll = value
		if value == null:
			_index = -1
var _index := -1

func show_info(scroll: Variant, index:=-1) -> void:
	hbox.show()
	_index = index

	if scroll is Attack:
		label.display_message_non_blocking(scroll)
		return

	_active_scroll = scroll
	label.display_message_non_blocking(scroll.spell)

func _on_cancel_button_pressed() -> void:
	_active_scroll = null
	hbox.hide()
	label.clear_message()
	spell_selected.emit(null)

func _on_learn_spell_button_pressed() -> void:
	spell_selected.emit(_active_scroll)
	_active_scroll = null
	hbox.hide()
	label.clear_message()

func _on_forget_spell_button_pressed() -> void:
	forget_spell_requested.emit(_index)
	_active_scroll = null
	hbox.hide()
	label.clear_message()
