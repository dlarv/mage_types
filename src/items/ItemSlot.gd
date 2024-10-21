@tool
extends Resource
class_name ItemSlot 

@export var item: Item
@export var id: int: 
	set(value):
		id = value
		if item != null: item.id = id
@export var quantity: int:
	set(value):
		quantity = value
		if item == null or not item is RegularItem: return
		if item.battle_item != null:
			item.battle_item.quantity = value
var allow_stacking := false

func setup(item: Item) -> void:
	if item == null: return
	self.item = item
	quantity = 0

	if item is RegularItem and item.battle_item != null:
		item.battle_item.quantity = quantity
