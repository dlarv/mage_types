extends PanelContainer 
class_name InventoryScreen 

signal item_selected(item)

@export
var infoPanel: InfoDisplay 
@export
var itemsScroller: VBoxContainer 
@export
var equipmentScroller: VBoxContainer 
@export
var spellsScroller: VBoxContainer 
@export
var keyItemsScroller: VBoxContainer 
@export
var tabContainer: TabContainer 
@export
var idCheckBox: CheckBox 
@export
var nameCheckBox: CheckBox 

func setup(inventory: Inventory) -> void:
	_populate_tab(inventory.items, itemsScroller)
	_populate_tab(inventory.equipment, equipmentScroller)
	_populate_tab(inventory.spell_scrolls, spellsScroller)
	_populate_tab(inventory.key_items, keyItemsScroller)

	inventory.quantity_changed.connect(on_quantity_changed)

func _populate_tab(items, scroller):
	for item in items:
		var button = Button.new()
		button.name = item.name

		button.set_meta("id", item.id)
		if "quantity" in item and item.quantity != -1:
			button.text = "%s (%d)" % [item.name, item.quantity]
		else:
			button.text = "%s" % item.name
		var temp = item

		button.pressed.connect(func(): 
			infoPanel.display_message_non_blocking(item)
			item_selected.emit(temp))
		scroller.add_child(button)

		button.disabled = "quantity" in item and item.quantity == 0

func sort_by_id(tab: int=-1) -> void:
	# This method is called when the user exits from this screen,
	# to help prevent potential bugs 
	# (id will likely be used as an index, so they need to be in ord).
	# When this happens, the checkboxes will not reset.
	idCheckBox.set_pressed_no_signal(true)
	nameCheckBox.set_pressed_no_signal(false)

	var scroller
	if tab == -1: tab = tabContainer.current_tab
	match tab:
		2: 
			scroller = spellsScroller
		1:
			scroller = equipmentScroller
		3:
			scroller = keyItemsScroller
		_:
			scroller = itemsScroller
	var buttons = scroller.get_children()
	buttons.get_children().sort_custom(func(a, b): return a.get_meta("id") < b.get_meta("id"))

	for i in range(len(buttons)):
		scroller.move_child(buttons[i], i)

func sort_by_alphabetical()-> void:
	# var buttons = Enumerable.OrderBy<Node, string>( itemsScroller.GetChildren(), (Node item) => item.name)
	var scroller
	match tabContainer.current_tab:
		2: 
			scroller = spellsScroller
		1:
			scroller = equipmentScroller
		3:
			scroller = keyItemsScroller
		_:
			scroller = itemsScroller

	var buttons = scroller.get_children()
	buttons.get_children().sort_custom(func(a, b): return a.name < b.name)

	for i in range(len(buttons)):
		scroller.move_child(buttons[i], i)

func on_quantity_changed(item: Item, amount: int) -> void:
	var scroller
	var tab
	if item is KeyItem:
		scroller = keyItemsScroller
		tab = 3
	elif item is SpellScroll:
		scroller = spellsScroller
		tab = 2
	elif item is Equipment:
		scroller = equipmentScroller
		tab = 1
	else:
		scroller = itemsScroller
		tab = 0

	sort_by_id(tab)

	var button = scroller.get_child(item.id)
	button.text = "%s (%d)" % [ item.name, amount ]

	if amount == 0: button.hide()

func on_tab_changed(index: int) -> void:
	sort_by_id()
