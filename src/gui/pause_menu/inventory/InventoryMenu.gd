extends Menu

signal regular_item_selected(item: _Item)
signal spell_scroll_selected(item: _Item)
signal equipment_selected(item: _Item)

func _ready() -> void:
	$Regular.setup(Inventory.regular_items)
	$"Spell Beads".setup(Inventory.spell_scrolls)
	$Equipment.setup(Inventory.equipment)
	$"Key Items".setup(Inventory.key_items.values())

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

func open_regular_menu() -> _Item:
	tabs_visible = false
	current_tab = 0
	var item: _Item = await regular_item_selected
	return item

func open_spell_scroll_menu() -> _Item:
	tabs_visible = false
	current_tab = 1
	var item: _Item = await spell_scroll_selected
	tabs_visible = true
	return item

func open_equipment_menu(onlyOverworldSpells:=false) -> _Item:
	if onlyOverworldSpells:
		$Equipment.filter(func(_item: _Item) -> bool:
			return _item.has_overworld_use
		)

	tabs_visible = false
	current_tab = 2
	var item: _Item = await equipment_selected
	tabs_visible = true

	if onlyOverworldSpells: 
		$Equipment.clear_filter()

	return item 

func _on_item_selected(item:_Item) -> void:
	if item is RegularItem:
		regular_item_selected.emit(item)
	elif item is SpellScroll:
		spell_scroll_selected.emit(item)
	elif item is Equipment:
		equipment_selected.emit(item)
