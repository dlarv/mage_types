extends Resource
class_name VendorItem

@export var item: Item
@export var cost: int
@export var disabled: bool

func _init(item: Resource=null, cost: int=-1):
	self.item = item
	self.cost = cost

