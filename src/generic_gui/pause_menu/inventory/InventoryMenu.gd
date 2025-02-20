extends Menu

func _ready() -> void:
	$Regular.setup(Inventory.regular_items)
	$"Spell Beads".setup(Inventory.spell_scrolls)
	$Equipment.setup(Inventory.equipment)
	$"Key Items".setup(Inventory.key_items)

	Inventory.quantity_changed.connect(_on_quantity_changed)


func _on_quantity_changed(item: ItemSlot) -> void:
	if item.item is RegularItem:
		$Regular.change_quantity(item)
	elif item.item is SpellScroll:
		$"Spell Beads".change_quantity(item)
	elif item.item is Equipment:
		$Equipment.change_quantity(item)
	else:
		$"Key Items".change_quantity(item)
