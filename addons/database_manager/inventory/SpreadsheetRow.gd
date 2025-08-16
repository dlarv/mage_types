@tool
extends Resource
@warning_ignore_start("untyped_declaration")
signal selected(row)

var inventory := Inventory

var select: CheckBox
var name: LineEdit
var quantity: SpinBox
var max_quantity: SpinBox
var description: TextEdit
var item_slot: ItemSlot

func _init(s=null, n=null, q=null, m=null, d=null, i=null, inventory=null) -> void:
	self.inventory = inventory
	item_slot = i

	select = s
	select.pressed.connect(func(): 
		EditorInterface.edit_resource(item_slot)
		selected.emit(self)
	)

	name = n
	name.text_submitted.connect(func(val): item_slot.item.name = val)

	quantity = q
	quantity.value_changed.connect(func(val): item_slot.quantity = val)

	max_quantity = m
	max_quantity.value_changed.connect(func(val): item_slot.max_quantity = val)

	description = d
	description.text_changed.connect(func(): item_slot.item.details = description.text)


func delete() -> void:
	select.queue_free()
	name.queue_free()
	quantity.queue_free()
	max_quantity.queue_free()
	description.queue_free()


func update() -> void:
	if item_slot:
		name.text = item_slot.item.name
		quantity.value = item_slot.quantity
		max_quantity.value = item_slot.max_quantity
		description.text = item_slot.item.details

