extends PanelContainer

const BASE_MAX_QUANTITY: int = 9999

@export var quantity_display: LineEdit
@export var info_display: InfoDisplay

var _available_funds: int = 0
var _max_quantity: int = BASE_MAX_QUANTITY
var _current_quantity: int = 0

func display(item: VendorItem) -> void:
	_available_funds = Inventory.money
	_current_quantity = 0
	quantity_display.text = ""

	var quantityLimit: int
	if item.item is RegularItem:
		quantityLimit = min(BASE_MAX_QUANTITY, item.item.max_quantity - item.item.quantity)
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
