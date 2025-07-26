extends Control

signal item_selected(item: VendorItem)

@export var cost_label: Label
@export var button: Button

func setup(item: VendorItem) -> void:
	cost_label.text = str(item.cost)
	button.text = item.item.name
	button.pressed.connect(func() -> void:
		item_selected.emit(item))
