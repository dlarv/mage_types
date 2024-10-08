@tool
extends Node 
class_name Inventory 

enum Category { REGULAR_ITEM, EQUIPMENT, SPELL_SCROLL, KEY_ITEM }

# NOTE: This is not called when loading from filesystem.
signal quantity_changed(item, amount);

var next_id = 0

@export var items: Array[Item] = []
@export var equipment: Array[Equipment] = []
@export var spell_scrolls: Array[SpellScroll] = []
@export var key_items: Array[KeyItem] = []

@export var money: int = 0

# Secondary reference to battle items.
var _battle_items: Array[BattleItem] = []

func _enter_tree() -> void:
	load_from_fs();

func get_battle_items() -> Array:
	return _battle_items;

func search(term: String):
	return null;

func load_from_fs()-> void:
	items = []
	key_items = []
	spell_scrolls = []
	equipment = []
	_battle_items = []

	load_from_dir("res://data/items/items/");
	load_from_dir("res://data/items/key_items/");
	load_from_dir("res://data/items/equipment/");
	load_from_dir("res://data/items/spell_scrolls/");

	# Lists should already be sorted.
	# Items.Sort();
	# KeyItems.Sort();
	# SpellScrolls.Sort();
	# Equipment.Sort();
func load_from_dir(path: String) -> void:
	var dir = DirAccess.open(path);
	var item = "temp";

	dir.list_dir_begin();
	while len(item) != 0 and dir != null:
		item = dir.get_next();

		if dir.file_exists(item):
			if !item.ends_with(".tres"): continue;

			var res = load(path + item);
			if(res == null): continue;
			if res is Equipment:
				equipment.append(res);
			elif res is KeyItem:
				key_items.append(res);
			elif res is SpellScroll:
				spell_scrolls.append(res);
			elif res is RegularItem:
				var battleItem = res.battle_item; 
				if battleItem != null:
					_battle_items.append(battleItem);
					if battleItem.is_consumable:
						battleItem.item_consumed.connect(func(): quantity_changed.emit(res, res.quantity))
				items.append(res);
			else:
				print(" is not an item, skipping" % res);
				continue;

			res.update_id(next_id);
			next_id += 1

		elif len(item) != 0 and dir.dir_exists(item):
			load_from_dir(path + item + "/");

func add(item: Item) -> void:
	var list = []
	var cat = Category.REGULAR_ITEM

	if item is Equipment:
		list = equipment;
		cat = Category.EQUIPMENT;
	
	elif item is KeyItem:
		list = key_items;
		cat = Category.KEY_ITEM;

	elif item is SpellScroll:
		list = spell_scrolls;
		cat = Category.SPELL_SCROLL;

	var index = list.binary_search(item);

	if list[index] == item:
		if list[index].try_combine(item):
			quantity_changed.emit(list[index], cat)
	else:
		list.insert(index, item);
		quantity_changed.emit(list[index], cat)

func remove(item: Item, amount: int=-1) -> Item:
	var list = []
	var cat = Category.REGULAR_ITEM;
	if item is Equipment:
		list = equipment;
		cat = Category.EQUIPMENT;
	
	elif item is KeyItem:
		list = key_items;
		cat = Category.KEY_ITEM;

	elif item is SpellScroll:
		list = spell_scrolls;
		cat = Category.SPELL_SCROLL;
	
	else: list = items;

	var index = list.binary_search(item);
	if list[index] == item:
		var output = list[index];
		list.remove_at(index);
		quantity_changed.emit(output, cat)
		return output;
	return null;

func get_item(item: Item) -> Item:
	return null
