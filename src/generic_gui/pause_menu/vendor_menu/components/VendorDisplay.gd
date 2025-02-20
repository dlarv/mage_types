extends PanelContainer

const BASE_MAX_QUANTITY: int = 9999

signal item_bought(item: Item, quantity: int)

@export var quantity_display: LineEdit
@export var info_display: InfoDisplay

var _available_funds := 0
var _max_quantity := BASE_MAX_QUANTITY
var _current_quantity := 0
var _current_item: Item = null


func display(item: VendorItem) -> void:
	_current_item = item.item
	_available_funds = Inventory.money
	_current_quantity = 0
	quantity_display.text = ""

	var quantityLimit: int
	var slot := Inventory.get_item(item.item)
	if item.item is RegularItem:
		quantityLimit = min(BASE_MAX_QUANTITY, slot.max_quantity - slot.quantity)
	else:
		quantityLimit = BASE_MAX_QUANTITY
	
	var costLimit: int 
	if item.cost != 0:
		@warning_ignore("integer_division")
		costLimit = Inventory.money / item.cost
	else:
		costLimit = BASE_MAX_QUANTITY

	_max_quantity = min(quantityLimit, costLimit)
	info_display.display_message_non_blocking(item.item)


func _on_quantity_button_pressed(quantity: int) -> void:
	_current_quantity += quantity

	if _current_quantity < 0:
		# If player pressed "<<" and quantity>0, snap to 0.
		if _current_quantity != -10 and quantity == -10:
			_current_quantity = 0
		# Else, wraparound to MAX.
		else:
			_current_quantity = _max_quantity
	elif _current_quantity > _max_quantity:
		if _current_quantity != _max_quantity + 10 and quantity == 10:
			_current_quantity = _max_quantity
		else:
			_current_quantity = 0
	
	quantity_display.text = str(_current_quantity)


func _on_cancel_button_pressed() -> void:
	info_display.clear_message()
	_current_quantity = 0
	_current_item = null
	quantity_display.text = ""


func _on_buy_button_pressed() -> void:
	item_bought.emit(_current_item, _current_quantity)
	_on_cancel_button_pressed()

