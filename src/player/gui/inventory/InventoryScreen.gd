extends PanelContainer 
class_name InventoryScreen 

signal ItemSelected(item)

@export
var infoPanel: InventoryDisplayPanel 
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

func Setup(inventory: Inventory) -> void:
	_populate_tab(inventory.items, itemsScroller)
	_populate_tab(inventory.equipment, equipmentScroller)
	_populate_tab(inventory.spell_scrolls, spellsScroller)
	_populate_tab(inventory.key_items, keyItemsScroller)

	inventory.QuantityChanged.connect(OnQuantityChanged)

func _populate_tab(items, scroller):
	for item in items:
		var button = Button.new()
		button.name = item.Name

		button.set_meta("id", item.Id)
		button.text = "%s (%d)" % [item.Name, item.Quantity]
		var temp = item

		button.pressed.connect(func():
			ItemSelected.emit(temp))
		scroller.add_child(button)

		if item.Quantity == 0:
			button.hide()

func SortById(tab: int=-1) -> void:
	# This method is called when the user exits from this screen,
	# to help prevent potential bugs 
	# (id will likely be used as an index, so they need to be in ord).
	# When this happens, the checkboxes will not reset.
	idCheckBox.set_pressed_no_signal(true)
	nameCheckBox.set_pressed_no_signal(false)

	# var buttons = Enumerable.OrderBy<Node, int>( itemsScroller.GetChildren(), (Node item) => (int)item.GetMeta("id"))

	var buttons = []
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

	for i in range(len(buttons)):
		scroller.move_child(buttons[i], i)

func SortByAlphabetical()-> void:
	# var buttons = Enumerable.OrderBy<Node, string>( itemsScroller.GetChildren(), (Node item) => item.Name)
	var buttons = []
	var scroller
	match tabContainer.CurrentTab:
		2: 
			scroller = spellsScroller
		1:
			scroller = equipmentScroller
		3:
			scroller = keyItemsScroller
		_:
			scroller = itemsScroller

	for i in range(len(buttons)):
		scroller.move_child(buttons[i], i)

func OnQuantityChanged(item: Item, amount: int) -> void:
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

	SortById(tab)

	var button = scroller.get_child(item.Id)
	button.Text = "%s (%d)" % [ item.name, amount ]

	if amount == 0: button.Hide()

func OnTabChanged(index: int) -> void:
	SortById()
