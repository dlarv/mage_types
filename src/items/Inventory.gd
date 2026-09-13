@tool
extends Node 

enum Category { REGULAR_ITEM, EQUIPMENT, SPELL_SCROLL, KEY_ITEM }

# NOTE: This is not called when loading from filesystem.
signal quantity_changed(item: ItemSlot)
signal overworld_spell_selected(item: Equipment)
signal key_item_obtained(item: KeyItem)
signal key_item_lost(item: KeyItem)

@export var money: int = 0

@export_category("_Item Arrays")
var _battle_items: Array[RegularItem]
@export var regular_items: Array[ItemSlot]:
	set(vals):
		regular_items = vals
		_battle_items = []
		for item in vals:
			if "battle_item" in item.item and item.item.battle_item != null:
				_battle_items.append(item.item)
				item.item.battle_item.item_consumed.connect(func() -> void:
					item.quantity -= 1
					quantity_changed.emit(item))
		_reorder_item_array(regular_items)
@export_tool_button("Recalc Ids") var rr := _reorder_item_array.bind(regular_items)
@export var spell_scrolls: Array[ItemSlot]:
	set(vals):
		spell_scrolls = vals
		_reorder_item_array(spell_scrolls)
@export_tool_button("Recalc Ids") var rs := _reorder_item_array.bind(spell_scrolls)
@export var equipment: Array[ItemSlot]:
	set(vals):
		equipment = vals
		_reorder_item_array(equipment)
@export_tool_button("Recalc Ids") var re := _reorder_item_array.bind(equipment)
@export var key_items: Dictionary[StringName, ItemSlot]
@export var _add_item: _Item:
	set(item):
		var list: Array
		if item is RegularItem:
			list = regular_items
			_try_add_battle_item(item)
		elif item is SpellScroll:
			list = spell_scrolls
		elif item is KeyItem:
			key_items[item.unique_name] = ItemSlot.new(item)
			return
		else:
			list = equipment

		item.id = len(list)
		list.append(ItemSlot.new(item))

## Copy-paste file path into here to recursively load all items in a directory.
## This will not check that an item has not been added yet!
@export var _add_item_dir: String:
	set(path):
		_add_items_from_dir(path)
		_add_item_dir = ""

@export var create_spell: Attack:
	set(val):
		var scroll := SpellScroll.new()
		scroll.spell = val
		scroll.name = "%s Bead" % val.name 
		scroll.id = len(spell_scrolls)

		var path :="res://data/items/spell_scrolls/output/%s.tres" % scroll.name.replace(" ", "_").to_lower()
		ResourceSaver.save(scroll, path)
		_add_item = ResourceLoader.load(path) as SpellScroll
func _try_add_battle_item(item: RegularItem)  -> void:
	if item.battle_item == null: 
		return
	if _battle_items == null:
		_battle_items = []
	_battle_items.append(item)
@export var add_all_items := false

@export_category("Overworld Spells")
@export_enum("NONE", "DESTROY")
var use_override := "NONE"

var active_spell: Equipment = null:
	set(val):
		active_spell = val
		overworld_spell_selected.emit(active_spell)


func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	if add_all_items:
		for item in regular_items:
			item.quantity = 99
		for item in spell_scrolls:
			item.quantity = 99
		for item in equipment:
			item.quantity = 99

	if ProjectSettings.get_setting("custom/battle/play_test_mode"): 
		use_override = "NONE"
		# for item in key_items:
		# 	item.quantity = 0
	elif add_all_items:
		for item: ItemSlot in key_items.values():
			item.quantity = 1

	match use_override:
		"DESTROY":
			pass



## Returns list of **RegularItems** that contain BattleItems.
func get_battle_items() -> Array[RegularItem]:
	return _battle_items


func add_items(items: Array[ItemSlot]) -> void:
	for slot in items:
		add(slot.item, slot.quantity)


func add(item: _Item, amount:=1) -> void:
	if amount < 0:
		remove(item, -amount)
		return
	if item.id == -1 and not item is KeyItem:
		_add_item = item
		return

	var list := []
	if item is SpellScroll:
		list = spell_scrolls
	elif item is RegularItem:
		list = regular_items
	elif item is Equipment:
		list = equipment
	else:
		add_key_item(item, amount)
		return

	# If this throws an index out of bounds error, something has gone wrong and it should crash.
	var slot: ItemSlot = list[item.id]
	_increment_quantity(slot, amount)


func _increment_quantity(slot: ItemSlot, amount: int) -> void:
	slot.quantity += amount

	if slot.quantity > slot.max_quantity:
		slot.quantity = slot.max_quantity

	quantity_changed.emit(slot)

func add_key_item(item: KeyItem, amount:=1) -> void:
	if amount < 0:
		remove_key_item(item, -amount)
		return
	key_item_obtained.emit(item)

	# If this throws an index out of bounds error, something has gone wrong and it should crash.
	var slot: ItemSlot = key_items[item.unique_name]
	_increment_quantity(slot, amount)


func remove(item: _Item, amount:=1) -> ItemSlot:
	if amount < 0:
		remove(item, -amount)
		return
	if item.id == -1: return null

	var list: Array[ItemSlot] = []
	if item is SpellScroll:
		list = spell_scrolls
	elif item is RegularItem:
		list = regular_items
	elif item is Equipment:
		list = equipment
	else:
		remove_key_item(item)
		return

	if item.id >= len(list): return null

	var slot := list[item.id]
	if slot.quantity == 0: return null
	slot.quantity -= amount
	quantity_changed.emit(slot)
	return slot


func remove_key_item(item: KeyItem, quantity:=1) -> void:
	key_item_lost.emit(item)

	var slot: ItemSlot = key_items[item.unique_name]
	_increment_quantity(slot, -quantity)


func has_key_item(id: StringName) -> bool:
	var slot: ItemSlot = key_items.get(id)
	return slot != null and slot.quantity > 0


func get_item(item: _Item) -> ItemSlot:
	if item.id == -1: return null

	var list := []
	if item is SpellScroll:
		list = spell_scrolls
	elif item is RegularItem:
		list = regular_items
	elif item is SpellScroll:
		list = spell_scrolls
	elif item is KeyItem:
		return key_items.get(item.unique_name)
	return list[item.id]


func find_and_add_item(item: Variant, type: Category, amount:=1) -> void:
	## String interpreted as a name
	## Int interpreted as index
	## Attack is passed along to legacy find_and_add_spell
	## KeyItems can be found using StringNames
	var list: Array
	match type:
		Category.REGULAR_ITEM:
			list = regular_items
		Category.EQUIPMENT:
			list = equipment 
		Category.SPELL_SCROLL:
			list = spell_scrolls
		_:
			if item is StringName or item is String:
				var key: String = item.to_upper().replace(" ", "_")
				add_key_item(key_items[key].item, amount)
				return
			else:
				push_error("KeyItems can only be found using their unique_name")
				return

	if item is int:
		_increment_quantity(list[item], amount)
		return
	elif item is Attack:
		find_and_add_spell(item, amount)
		return
	
	# Find slot based on name
	for slot: ItemSlot in list:
		if slot.item.name == item:
			_increment_quantity(slot, amount)
			return
	push_warning("Could not find Item(%s)" % String(item))


# Kept for legacy purposes
func find_and_add_spell(spell: Attack, amount:=1) -> void:
	for slot in spell_scrolls:
		if slot.item.spell == spell:
			_increment_quantity(slot, amount)
			return


func select_overworld_spell(id: OverworldSpell.Spells, isPrimary:=true) -> void:
	overworld_spell_selected.emit(id, isPrimary)


func _add_items_from_dir(path: String) -> void:
		var root := DirAccess.open(path)

		# Depth first search of files.
		root.list_dir_begin()
		var file := root.get_next()
		while len(file) > 0 and root != null:
			if root.file_exists(file) and file.ends_with(".tres"):
				var item := load(path + file)
				if item is _Item: 
					_add_item = item

			elif root.dir_exists(file):
				_add_items_from_dir(path + file + "/")

			file = root.get_next()


func _reorder_item_array(list: Array[ItemSlot]) -> void:
	var i := 0
	for item in list:
		item.item.id = i
		i += 1

		if Engine.is_editor_hint():
			var err := ResourceSaver.save(item.item, item.item.resource_path)
			# print("Overwriting %s.......%s" % [item.item.resource_path, error_string(err)])


func serialize() -> Dictionary:
	var reg := []
	for item in regular_items:
		if item.quantity > 0:
			reg.append(Vector2i(item.id, item.quantity))

	var scrolls := []
	for item in spell_scrolls:
		if item.quantity > 0:
			scrolls.append(Vector2i(item.id, item.quantity))

	var es := []
	for item in equipment:
		if item.quantity > 0:
			es.append(Vector2i(item.id, item.quantity))

	var ki := []
	for item: ItemSlot in key_items.values():
		if item.quantity > 0:
			ki.append(Vector2i(item.id, item.quantity))

	return {
		"path": get_path(),
		"regular_items": reg,
		"spells": scrolls,
		"equipment": es,
		"key_items": ki,
		"active_spell": active_spell,
	}


func deserialize(data: Dictionary) -> void:
	var top := 0
	var list: Array = data["regular_items"]
	for item in regular_items:
		if len(list) > top and item.id == list[top].x:
			item.quantity = list[top].y
			top += 1
		else:
			item.quantity = 0
		quantity_changed.emit(item)

	top = 0
	list = data["spells"]
	for item in spell_scrolls: 
		if len(list) > top and item.id == list[top].x:
			item.quantity = list[top].y
			top += 1
		else:
			item.quantity = 0
		quantity_changed.emit(item)

	top = 0
	list = data["equipment"]
	for item in equipment:
		var id := item.id
		if len(list) > top and item.id == list[top].x:
			item.quantity = list[top].y
			top += 1
		else:
			item.quantity = 0
		quantity_changed.emit(item)

	top = 0
	list = data["key_items"]
	for item: ItemSlot in key_items.values():
		if len(list) > top and item.id == list[top].x:
			add_key_item(key_items[list[top].x].item)
			top += 1
		else:
			item.quantity = 0
		quantity_changed.emit(item)

	Inventory.active_spell = data['active_spell']
