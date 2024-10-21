@tool
extends Node 

enum Category { REGULAR_ITEM, EQUIPMENT, SPELL_SCROLL, KEY_ITEM }

# NOTE: This is not called when loading from filesystem.
signal quantity_changed(item: ItemSlot)

@export var money: int = 0

@export_category("Item Arrays")
@export var _items: Array[ItemSlot]
@export var regular_items: Array[ItemSlot]:
	get:
		return _items.slice(_regular_index.x, _regular_index.y) as Array[ItemSlot]
	set(values):
		if not Engine.is_editor_hint: return
		_combine_items(values, spell_scrolls)
@export var spell_scrolls: Array[ItemSlot]:
	get:
		return _items.slice(_scroll_index.x, _scroll_index.y) as Array[ItemSlot]
	set(values):
		if not Engine.is_editor_hint: return
		_combine_items(regular_items, values)
## Indices of start(inclusive) and end(exclusive) of category into _items array.
@export var _regular_index := Vector2i.ZERO
@export var _scroll_index := Vector2i.ZERO

### FIELDS
# var regular_items: Array:
# 	get:
# 		return _items.slice(_regular_index.x, _regular_index.y).map(func(slot): return slot.item)
# var spell_scrolls: Array:
# 	get:
# 		return _items.slice(_scroll_index.x, _scroll_index.y).map(func(slot): return slot.item)

# Secondary reference to battle regular_items.
var _battle_items: Array[BattleItem] = []
var next_id := 0


func _ready() -> void:
	if len(_items) == 0:
		_load_from_fs()
		return

func get_battle_items() -> Array:
	return _battle_items

func add(item: Item, amount=1) -> void:
	var list := []
	var cat := Category.REGULAR_ITEM

	if item is SpellScroll:
		list = spell_scrolls
		cat = Category.SPELL_SCROLL
	elif item is RegularItem:
		list = regular_items
	else:
		# NOT YET IMPLEMENTED
		return
	var index = list.bsearch_custom(item, func(a, b): return a.id < b.id)
	var slot = list[index]

	if slot.allow_stacking:
		slot.quantity += amount
		quantity_changed.emit(slot)
	elif slot.quantity == 0:
		slot.quantity = 1
		quantity_changed.emit(slot)


func remove(item: Item, amount: int=-1) -> ItemSlot:
	var list := []
	var cat := Category.REGULAR_ITEM

	if item is SpellScroll:
		list = spell_scrolls
		cat = Category.SPELL_SCROLL
	elif item is RegularItem:
		list = regular_items
	else:
		# NOT YET IMPLEMENTED
		return null

	var index = list.bsearch_custom(item, func(a, b): return a.id < b.id)
	var slot = list[index]

	if slot.quantity == 0: return null
	quantity_changed.emit(slot)
	return slot

func get_item(item: Item) -> Item:
	return null

func _combine_items(regularItems: Array, spellScrolls: Array) -> void:
	_items.clear()
	var start: int

	_items.append_array(regularItems)
	_regular_index = Vector2i(0, len(_items))
	start = len(_items)

	_items.append_array(spellScrolls)
	_scroll_index = Vector2i(start, len(_items))

	_battle_items.clear()
	for slot in regularItems:
		slot.allow_stacking = true
		if slot.item.battle_item != null:
			_battle_items.append(slot.item.battle_item)

func _load_from_fs()-> void:
	var regularItems = []
	var keyItems = []
	var spellScrolls = []
	var equipment = []
	_battle_items = []
	_items = []

	var loadFromDir: Callable
	loadFromDir = func(path: String) -> void:
		var dir := DirAccess.open(path)
		var item := "item"

		dir.list_dir_begin()
		while len(item) != 0 and dir != null:
			item = dir.get_next()

			if dir.file_exists(item):
				if !item.ends_with(".tres"): continue

				var res = load(path + item)
				if(res == null): continue
				if not res is Item:
					print(" is not an item, skipping" % res)
					continue
				
				var slot = ItemSlot.new()
				slot.setup(res)

				if res is Equipment:
					equipment.append(slot)
				elif res is KeyItem:
					keyItems.append(slot)
				elif res is SpellScroll:
					spellScrolls.append(slot)
				elif res is RegularItem:
					var battleItem = res.battle_item 
					if battleItem != null:
						_battle_items.append(battleItem)
						if battleItem.is_consumable:
							battleItem.item_consumed.connect(func(): quantity_changed.emit(res, res.quantity))
					regularItems.append(slot)

				slot.id = next_id
				next_id += 1

			elif len(item) != 0 and dir.dir_exists(item):
				loadFromDir.call(path + item + "/")

	loadFromDir.call("res://data/items/regular_items/")
	loadFromDir.call("res://data/items/key_items/")
	loadFromDir.call("res://data/items/equipment/")
	loadFromDir.call("res://data/items/spell_scrolls/")

	var start := 0

	_items.append_array(regularItems)
	_regular_index = Vector2i(0, len(_items))
	start = len(_items) 

	_items.append_array(spellScrolls)
	_scroll_index = Vector2i(start, len(_items))
