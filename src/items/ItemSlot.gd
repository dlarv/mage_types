@tool
extends Resource
class_name ItemSlot 

@export var item: _Item:
	set(value):
		item = value
		if value != null:
			resource_name = item.name
			if item == null or not item is RegularItem: return
			if item.battle_item:
				item.battle_item.quantity = quantity
@export var id: int: 
	get:
		if item == null: return -1
		return item.id
@export var quantity := 1:
	set(value):
		quantity = value
		if item == null or not item is RegularItem: return
		if item.battle_item:
			item.battle_item.quantity = value
@export var max_quantity := 9999
@export var allow_stacking: bool:
	get:
		return item and (not item is KeyItem)


func _init(item: _Item = null) -> void:
	if item == null: return
	self.item = item
	quantity = 0

	if item is RegularItem and item.battle_item != null:
		item.battle_item.quantity = quantity
