@tool
extends Resource
class_name VendorItem

@export var item: Item:
	set(value):
		item = value
		if item != null:
			resource_name = item.name
@export var cost: int
@export var disabled: bool

func _init(item: Item=null, cost: int=0):
	self.item = item
	self.cost = cost

