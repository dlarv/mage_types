@tool
extends Node3D
class_name VendorActor

@export var items: Array[VendorItem]
@export var spells: Array[VendorItem]

@export var add_item: Item:
	set(item):
		if item is RegularItem:
			items.append(VendorItem.new(item))
		elif item is SpellScroll:
			spells.append(VendorItem.new(item))


