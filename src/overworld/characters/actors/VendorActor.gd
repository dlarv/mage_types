@tool
extends StoryActor
class_name VendorActor

@export var items: Array[VendorItem]
@export var spells: Array[VendorItem]

@export var add_item: Item:
	set(item):
		if item is RegularItem:
			items.append(VendorItem.new(item))
		elif item is SpellScroll:
			spells.append(VendorItem.new(item))

# Override
func start_dialog():
	dialog_started.emit(dialog_ids[current_id], self)

