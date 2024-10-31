@tool
extends Node 

enum Category { REGULAR_ITEM, EQUIPMENT, SPELL_SCROLL, KEY_ITEM }

# NOTE: This is not called when loading from filesystem.
signal quantity_changed(item: ItemSlot)

@export var money: int = 0

@export_category("Item Arrays")
@export var reload_items := false:
	set(value):
		if not value or not Engine.is_editor_hint(): return
		_load_from_fs()
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



# Secondary reference to battle regular_items.
var _battle_items: Array[BattleItem] = []
var next_id := {
	Category.REGULAR_ITEM: 0,
	Category.SPELL_SCROLL: 0
}


func _ready() -> void:
	if len(_items) == 0:
		_load_from_fs()
		return

func get_battle_items() -> Array:
	return _battle_items

func add(item: Item, amount=1) -> void:
	var list := []

	if item is SpellScroll:
		list = spell_scrolls
	elif item is RegularItem:
		list = regular_items
	else:
		# NOT YET IMPLEMENTED
		return
	var index = list \
			.map(func(a): return a.item) \
			.bsearch_custom(item, func(a: Item, b: Item): return a.id < b.id)
	var slot = list[index]

	if slot.allow_stacking:
		slot.quantity += amount
		quantity_changed.emit(slot)

	elif slot.quantity == 0:
		slot.quantity = 1
		quantity_changed.emit(slot)

func remove(item: Item, amount: int=-1) -> ItemSlot:
	var list := []

	if item is SpellScroll:
		list = spell_scrolls
	elif item is RegularItem:
		list = regular_items
	else:
		# NOT YET IMPLEMENTED
		return null

	var index = list \
			.map(func(a): return a.item) \
			.bsearch_custom(item, func(a: Item, b: Item): return a.id < b.id)
	var slot = list[index]

	if slot.quantity == 0: return null
	quantity_changed.emit(slot)
	return slot

func get_item(item: Item) -> ItemSlot:
	var list := []
	if item is SpellScroll:
		list = spell_scrolls
	elif item is RegularItem:
		list = regular_items
	else:
		# NOT YET IMPLEMENTED
		return
	var dummySlot = ItemSlot.new(item)
	var index = list.bsearch_custom(dummySlot, func(a, b): return a.id < b.id)
	return list[index]

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

	print("Loading regular items")
	regularItems = _load_from_dir.call("res://data/items/regular_items/", regular_items)
	print("\nLoading spell scrolls")
	spellScrolls = _load_from_dir.call("res://data/items/spell_scrolls/", spell_scrolls)

	var start := 0
	_items = []

	_items.append_array(regularItems)
	_regular_index = Vector2i(0, len(_items))
	start = len(_items) 

	_items.append_array(spellScrolls)
	_scroll_index = Vector2i(start, len(_items))

func _load_from_dir(path: String, originalDir:=[], nextId:=0) -> Array:
	var output := []
	var root := DirAccess.open(path)
	var file := "file"
	var dirs := []

	print("Opening directory: %s" % path)
	root.list_dir_begin()
	while len(file) != 0 and root != null:
		file = root.get_next()

		if root.file_exists(file):
			if !file.ends_with(".tres"): continue

			var item = load(path + file)
			if(item == null): continue
			if not item is Item: continue

			print("Loaded %s" % file)
			var slot = ItemSlot.new()
			slot.setup(item)
			output.append(slot)
			
			var matches = originalDir.filter(func(a): return a.id == slot.item.id)
			# Copy over data.
			for m in matches:
				if slot.item == m.item:
					slot.quantity = m.quantity

			slot.id = nextId 
			nextId += 1

			if "battle_item" in item and item.battle_item != null:
				var battleItem = item.battle_item 
				if battleItem != null:
					_battle_items.append(battleItem)
					if battleItem.is_consumable:
						battleItem.item_consumed.connect(func(): quantity_changed.emit(item, item.quantity))

		elif len(file) != 0 and root.dir_exists(file):
			dirs.append(path + file + "/")
	
	for dir in dirs:
		var subdir = _load_from_dir(dir, originalDir, nextId)
		nextId += len(subdir)
		output.append_array(subdir)

	return output
