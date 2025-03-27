extends Menu

signal regular_item_selected(item: Item)
signal spell_scroll_selected(item: Item)
signal equipment_selected(item: Item)

var overworld_spells_menu: Control

func _ready():
	$Regular.setup(Inventory.regular_items)
	$"Spell Beads".setup(Inventory.spell_scrolls)
	$Equipment.setup(Inventory.equipment)
	$"Key Items".setup(Inventory.key_items)
	overworld_spells_menu = $"Overworld Spells"

	Inventory.quantity_changed.connect(_on_quantity_changed)
	setup()

func setup() -> void:
	$"Overworld Spells".setup()

func _on_quantity_changed(item: ItemSlot) -> void:
	if item.item is RegularItem:
		$Regular.change_quantity(item)
	elif item.item is SpellScroll:
		$"Spell Beads".change_quantity(item)
	elif item.item is Equipment:
		$Equipment.change_quantity(item)
	else:
		$"Key Items".change_quantity(item)

func open_regular_menu() -> Item:
	tabs_visible = false
	current_tab = 0
	var item = await regular_item_selected
	return item

func open_spell_scroll_menu() -> Item:
	tabs_visible = false
	current_tab = 1
	var item = await spell_scroll_selected
	return item

func open_equipment_menu() -> Item:
	tabs_visible = false
	current_tab = 2
	var item = await equipment_selected
	return item 

func _on_item_selected(item:Item) -> void:
	if item is RegularItem:
		regular_item_selected.emit(item)
	elif item is SpellScroll:
		spell_scroll_selected.emit(item)
	elif item is Equipment:
		equipment_selected.emit(item)

