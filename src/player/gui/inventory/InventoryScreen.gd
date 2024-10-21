extends PanelContainer 
class_name InventoryScreen 

signal item_selected(item)

@export var info_panel: InfoDisplay 
@export var items_scroller: VBoxContainer 
@export var equipment_scroller: VBoxContainer 
@export var spells_scroller: VBoxContainer 
@export var key_items_scroller: VBoxContainer 
@export var tab_container: TabContainer 
@export var id_check_box: CheckBox 
@export var name_check_box: CheckBox 

func _ready() -> void:
	_populate_tab(Inventory.regular_items, items_scroller)
	_populate_tab(Inventory.spell_scrolls, spells_scroller)

	Inventory.quantity_changed.connect(on_quantity_changed)

func _populate_tab(slots: Array, scroller: VBoxContainer) -> void:
	for slot in slots:
		var item: Item = slot.item
		var button = Button.new()
		button.name = item.name

		button.set_meta("id", item.id)
		if "quantity" in item and slot.quantity != -1:
			button.text = "%s (%d)" % [item.name, slot.quantity]
		else:
			button.text = "%s" % item.name

		button.pressed.connect(func(): 
			info_panel.display_message_non_blocking(slot)
			item_selected.emit(item))
		scroller.add_child(button)

		button.disabled = slot.quantity == 0

func sort_by_id(tab: int=-1) -> void:
	# This method is called when the user exits from this screen,
	# to help prevent potential bugs 
	# (id will likely be used as an index, so they need to be in ord).
	# When this happens, the checkboxes will not reset.
	id_check_box.set_pressed_no_signal(true)
	name_check_box.set_pressed_no_signal(false)

	var scroller
	if tab == -1: tab = tab_container.current_tab
	match tab:
		2: 
			scroller = spells_scroller
		1:
			scroller = equipment_scroller
		3:
			scroller = key_items_scroller
		_:
			scroller = items_scroller
	var buttons = scroller.get_children()
	buttons.sort_custom(func(a, b): return a.get_meta("id") < b.get_meta("id"))

	for i in range(len(buttons)):
		scroller.move_child(buttons[i], i)

func sort_by_alphabetical()-> void:
	# var buttons = Enumerable.OrderBy<Node, string>( items_scroller.GetChildren(), (Node item) => item.name)
	var scroller
	match tab_container.current_tab:
		2: 
			scroller = spells_scroller
		1:
			scroller = equipment_scroller
		3:
			scroller = key_items_scroller
		_:
			scroller = items_scroller

	var buttons = scroller.get_children()
	buttons.get_children().sort_custom(func(a, b): return a.name < b.name)

	for i in range(len(buttons)):
		scroller.move_child(buttons[i], i)

func on_quantity_changed(slot: ItemSlot) -> void:
	var scroller 
	var tab: int
	var item := slot.item
	if item is KeyItem:
		scroller = key_items_scroller
		tab = 3
	elif item is SpellScroll:
		scroller = spells_scroller
		tab = 2
	elif item is Equipment:
		scroller = equipment_scroller
		tab = 1
	else:
		scroller = items_scroller
		tab = 0

	sort_by_id(tab)

	var button = scroller.get_child(item.id)
	button.text = "%s (%d)" % [ item.name, slot.quantity ]

	if slot.quantity == 0: button.hide()

func on_tab_changed(index: int) -> void:
	sort_by_id()
