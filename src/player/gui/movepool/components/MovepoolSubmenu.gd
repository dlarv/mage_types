@tool
extends VBoxContainer

signal show_info_requested(spell)

@export
var scroller: VBoxContainer

func setup(movepool: Movepool):
	for slot in movepool.slots:
		var button = Button.new()
		button.text = slot.spell.name
		button.visible = slot.quantity == 1
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		button.pressed.connect(func(): show_info_requested.emit(slot.spell))
		
		scroller.add_child(button)
