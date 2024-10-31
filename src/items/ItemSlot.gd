@tool
extends Resource
class_name ItemSlot 

@export var item: Item:
	set(value):
		item = value
		if value != null:
			resource_name = item.name
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
@export var max_quantity := 9999
var allow_stacking := false


func _init(item: Item = null):
	if item == null: return
	self.item = item
	quantity = 0

	if item is RegularItem and item.battle_item != null:
		item.battle_item.quantity = quantity

