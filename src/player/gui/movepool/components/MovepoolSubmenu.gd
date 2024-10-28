@tool
extends VBoxContainer

signal show_info_requested(scroll)

@export var scroller: VBoxContainer

func setup() -> void:
	for slot in Inventory.spell_scrolls:
		var button = Button.new()
		button.text = slot.item.spell.name
		button.visible = slot.quantity > 0
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		button.pressed.connect(func(): show_info_requested.emit(slot.item))
		
		scroller.add_child(button)

	Inventory.quantity_changed.connect(func(slot: ItemSlot): 
		if not slot.item is SpellScroll: return
		var child = scroller.get_child(slot.id)
		child.visible = slot.quantity > 0)
