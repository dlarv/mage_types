@tool
extends Node 

enum Category { REGULAR_ITEM, EQUIPMENT, SPELL_SCROLL, KEY_ITEM }

# NOTE: This is not called when loading from filesystem.
signal quantity_changed(item: ItemSlot)
signal overworld_spell_selected(id: OverworldSpell.Spells, isPrimary: bool)
signal overworld_spell_enabled(id: OverworldSpell.Spells, isEnabled: bool)

@export var money: int = 0

@export_category("Item Arrays")
var _battle_items: Array
@export var regular_items: Array[ItemSlot]:
	set(vals):
		regular_items = vals
		_battle_items = []
		for item in vals:
			if "battle_item" in item.item and item.item.battle_item != null:
				_battle_items.append(item.item.battle_item)
				item.item.battle_item.item_consumed.connect(func():
					item.quantity -= 1
					quantity_changed.emit(item))
		_reorder_item_array(regular_items)
@export var recalc_ids_r: bool:
	set(val):
		_reorder_item_array(regular_items)
@export var spell_scrolls: Array[ItemSlot]:
	set(vals):
		spell_scrolls = vals
		_reorder_item_array(spell_scrolls)
@export var recalc_ids_s: bool:
	set(val):
		_reorder_item_array(spell_scrolls)
@export var key_items: Array[ItemSlot]:
	set(vals):
		key_items = vals
		_reorder_item_array(key_items)
@export var recalc_ids_k: bool:
	set(val):
		_reorder_item_array(key_items)
@export var equipment: Array[ItemSlot]:
	set(vals):
		equipment = vals
		_reorder_item_array(equipment)
@export var recalc_ids_e: bool:
	set(val):
		_reorder_item_array(equipment)
@export var _add_item: Item:
	set(item):
		var list: Array
		if item is RegularItem:
			list = regular_items
			_try_add_battle_item(item)
		elif item is SpellScroll:
			list = spell_scrolls
		elif item is KeyItem:
			list = key_items
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
func _try_add_battle_item(item: RegularItem)  -> void:
	if item.battle_item == null: 
		return
	if _battle_items == null:
		_battle_items = []
	_battle_items.append(item)

@export_category("Overworld Spells")
@export var stasis_spell_enabled: bool
@export var destroy_spell_enabled: bool
@export var vines_spell_enabled: bool
@export var catalyst_spell_enabled: bool
@export var tunnel_spell_enabled: bool
@export var primary_override: OverworldSpell.Spells
@export var secondary_override: OverworldSpell.Spells
@export var use_override: bool

var spell1: OverworldSpell.Spells
var spell2: OverworldSpell.Spells

## Returns list of **RegularItems** that contain BattleItems.
func get_battle_items() -> Array:
	return _battle_items

func add(item: Item, amount:=1) -> void:
	if amount < 0:
		remove(item, -amount)
		return
	if item.id == -1:
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
		list = key_items

	# If this throws an index out of bounds error, something has gone wrong and it should crash.
	var slot: ItemSlot = list[item.id]

	if slot.allow_stacking:
		slot.quantity += amount
		quantity_changed.emit(slot)

	elif slot.quantity == 0:
		slot.quantity = 1
		quantity_changed.emit(slot)

func add_spell(spell: Attack) -> void:
	for slot in spell_scrolls:
		if slot.item.spell == spell:
			slot.quantity += 1
			quantity_changed.emit(slot)
			return

func remove(item: Item, amount:=1) -> ItemSlot:
	if amount < 0:
		remove(item, -amount)
		return
	if item.id == -1: return null

	var list := []
	if item is SpellScroll:
		list = spell_scrolls
	elif item is RegularItem:
		list = regular_items
	else:
		# NOT YET IMPLEMENTED
		return null

	if item.id >= len(list): return null

	var slot = list[item.id]
	if slot.quantity == 0: return null
	slot.quantity -= amount
	quantity_changed.emit(slot)
	return slot

func get_item(item: Item) -> ItemSlot:
	if item.id == -1: return null

	var list := []
	if item is SpellScroll:
		list = spell_scrolls
	elif item is RegularItem:
		list = regular_items
	elif item is SpellScroll:
		list = spell_scrolls
	elif item is KeyItem:
		list = key_items

	return list[item.id]

func enable_overworld_spell(id: OverworldSpell.Spells, val:=true) -> void:
	match id:
		OverworldSpell.Spells.STASIS: 
			stasis_spell_enabled = val
		OverworldSpell.Spells.CATALYST: 
			catalyst_spell_enabled = val
		OverworldSpell.Spells.DESTROY: 
			destroy_spell_enabled = val
		OverworldSpell.Spells.VINES: 
			vines_spell_enabled = val
		_: 
			tunnel_spell_enabled = val
	overworld_spell_enabled.emit(id, val)

func select_overworld_spell(id: OverworldSpell.Spells, isPrimary:=true) -> void:
	overworld_spell_selected.emit(id, isPrimary)
	if isPrimary:
		spell1 = id
	else:
		spell2 = id

func _add_items_from_dir(path: String) -> void:
		print("Loading items from: " + path)
		var root := DirAccess.open(path)

		# Depth first search of files.
		root.list_dir_begin()
		var file := root.get_next()
		while len(file) > 0 and root != null:
			if root.file_exists(file) and file.ends_with(".tres"):
				var item := load(path + file)
				if item is Item: 
					_add_item = item

			elif root.dir_exists(file):
				_add_items_from_dir(path + file + "/")

			file = root.get_next()


func _reorder_item_array(list: Array) -> void:
	var i := 0
	for item in list:
		item.item.id = i
		i += 1

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
	for item in key_items:
		if item.quantity > 0:
			ki.append(Vector2i(item.id, item.quantity))

	return {
		"path": get_path(),
		"regular_items": reg,
		"spells": scrolls,
		"equipment": es,
		"key_items": ki,
		"stasis": stasis_spell_enabled,
		"catalyst": catalyst_spell_enabled,
		"destroy": destroy_spell_enabled,
		"vines": vines_spell_enabled,
		"tunnel": tunnel_spell_enabled,
		"spell1": spell1,
		"spell2": spell2,
	}

func deserialize(data: Dictionary) -> void:
	var top := 0
	var list = data["regular_items"]
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
		var id = item.id
		if len(list) > top and item.id == list[top].x:
			item.quantity = list[top].y
			top += 1
		else:
			item.quantity = 0
		quantity_changed.emit(item)

	top = 0
	list = data["key_items"]
	for item in key_items:
		if len(list) > top and item.id == list[top].x:
			item.quantity = list[top].y
			top += 1
		else:
			item.quantity = 0
		quantity_changed.emit(item)

	enable_overworld_spell(OverworldSpell.Spells.STASIS, data["stasis"])
	enable_overworld_spell(OverworldSpell.Spells.CATALYST, data["catalyst"])
	enable_overworld_spell(OverworldSpell.Spells.DESTROY, data["destroy"])
	enable_overworld_spell(OverworldSpell.Spells.VINES, data["vines"])
	enable_overworld_spell(OverworldSpell.Spells.TUNNEL, data["tunnel"])

	UIManager.inventory.overworld_spells_menu.set_primary(data["spell1"])
	UIManager.inventory.overworld_spells_menu.set_secondary(data["spell2"])
