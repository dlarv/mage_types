@tool
extends PanelContainer

const Row := preload("SpreadsheetRow.gd")
const InventoryScene := preload("res://src/items/Inventory.tscn")

var inventory := Inventory
var rows: Array[Row]

var _button_group := ButtonGroup.new()
var _selected_row: Row = null


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		inventory = InventoryScene.instantiate(PackedScene.GenEditState.GEN_EDIT_STATE_MAIN)

	_on_load_button_pressed()


func add_row(itemSlot: ItemSlot) -> void:
	var select := CheckBox.new()
	select.button_group = _button_group

	var name := LineEdit.new()
	name.text = "Blank Potion"

	var quantity := SpinBox.new()
	quantity.value = 0
	quantity.max_value = 9999

	var maxQuantity := SpinBox.new()
	maxQuantity.value = 9999
	maxQuantity.max_value = 9999

	var description := TextEdit.new()
	description.custom_minimum_size.y = 50

	var row: Row = Row.new(select, name, quantity, maxQuantity, description, itemSlot, inventory)
	row.selected.connect(_on_row_selected)
	rows.append(row)

	var scroller: GridContainer
	if itemSlot:
		name.text = itemSlot.item.name
		quantity.value = itemSlot.quantity
		maxQuantity.value = itemSlot.max_quantity
		description.text = itemSlot.item.details
		if itemSlot.item is RegularItem:
			scroller = %RegularItemScroller
		elif itemSlot.item is SpellScroll:
			scroller = %SpellScrollScroller
		elif itemSlot.item is Equipment:
			scroller = %EquipmentScroller
		else:
			scroller = %KeyItemScroller
	else:
		match $TabContainer.current_tab:
			0: scroller = %RegularItemScroller
			1: scroller = %SpellScrollScroller
			2: scroller = %EquipmentScroller
			_: scroller = %KeyItemScroller

	scroller.add_child(select)
	scroller.add_child(name)
	scroller.add_child(quantity)
	scroller.add_child(maxQuantity)
	scroller.add_child(description)


func remove_row() -> void:
	if not _selected_row: return
	_selected_row.delete()
	rows.remove_at(rows.find(_selected_row))


func _on_row_selected(row: Row) -> void:
	_selected_row = row


func _on_load_button_pressed() -> void:
	for row in rows:
		row.delete()
	rows = []

	for item in inventory.regular_items:
		add_row(item)
	for item in inventory.spell_scrolls:
		add_row(item)
	for item in inventory.equipment:
		add_row(item)
	for item in inventory.key_items:
		add_row(item)
