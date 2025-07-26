extends Menu

signal menu_closed()

@export var VendorItemSelector: PackedScene
@export var info_display: PanelContainer
@export var tab_container: TabContainer
@export var item_scroller: VBoxContainer
@export var scroll_scroller: VBoxContainer
@export var label: Label

var current_vendor: VendorActor = null

func _ready() -> void:
	info_display.item_bought.connect(Inventory.add)

func open_menu(vendor: VendorActor) -> void:
	show()
	if current_vendor == vendor: return
	current_vendor = vendor
	label.text = "%s's Store" % current_vendor.name

	for child in item_scroller.get_children():
		item_scroller.remove_child(child)

	for item in vendor.items:
		if item == null: continue
		var selector := VendorItemSelector.instantiate()
		selector.setup(item)
		selector.item_selected.connect(_on_item_selected)

		item_scroller.add_child(selector)

	for item in vendor.spells:
		if item == null: continue
		var selector := VendorItemSelector.instantiate()
		selector.setup(item)
		selector.item_selected.connect(_on_item_selected)

		scroll_scroller.add_child(selector)

	tab_container.tabs_visible = item_scroller.get_child_count() > 0 and scroll_scroller.get_child_count() > 0
	tab_container.current_tab = 1 if item_scroller.get_child_count() == 0 else 0

func _on_item_selected(item: VendorItem) -> void:
	info_display.display(item)

func _on_hidden() -> void:
	menu_closed.emit()
