@tool
extends Resource
class_name VendorItem

@export var item: _Item:
	set(value):
		item = value
		if item != null:
			resource_name = item.name
@export var cost: int
@export var disabled: bool

func _init(item: _Item=null, cost: int=0) -> void:
	self.item = item
	self.cost = cost

