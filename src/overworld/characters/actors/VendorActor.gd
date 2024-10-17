@tool
extends StoryActor
class_name VendorActor

@export var items: Array[VendorItem]

# Override
func start_dialog():
	dialog_started.emit(dialog_ids[current_id], self)

