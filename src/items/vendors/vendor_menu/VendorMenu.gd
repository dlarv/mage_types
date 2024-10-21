extends PanelContainer
class_name VendorMenu

signal menu_closed()

@export var VendorItemSelector: PackedScene
@export var info_display: PanelContainer
@export var item_scroller: VBoxContainer
@export var label: Label

var _current_vendor_name := ""

func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	if event.is_action_pressed("close_menu"):
		get_window().set_input_as_handled()
		hide()

func open_menu(vendor: VendorActor) -> void:
	show()
	if vendor.actor_name == _current_vendor_name: return
	_current_vendor_name = vendor.actor_name
	label.text = "%s's Store" % _current_vendor_name

	for child in item_scroller.get_children():
		item_scroller.remove_child(child)

	for item in vendor.items:
		var selector = VendorItemSelector.instantiate()
		selector.setup(item)
		selector.item_selected.connect(_on_item_selected)
		item_scroller.add_child(selector)

func _on_item_selected(item: VendorItem) -> void:
	info_display.display(item)

func _on_hidden() -> void:
	menu_closed.emit()
