@tool
extends Node 
class_name Inventory 

enum Category { Item, Equipment, SpellScroll, KeyItem }

# NOTE: This is not called when loading from filesystem.
signal QuantityChanged(item, amount);

var next_id = 0

@export
var items: Array[Item] = []
@export
var equipment: Array[Equipment] = []
@export
var spell_scrolls: Array[SpellScroll] = []
@export
var key_items: Array[KeyItem] = []

# Secondary reference to battle items.
var battleItems: Array[BattleItem] = []

func _enter_tree() -> void:
	LoadFromFS();

func GetBattleItems():
	return battleItems;

func Search(term: String):
	return null;

func LoadFromFS()-> void:
	items = []
	key_items = []
	spell_scrolls = []
	equipment = []
	battleItems = []

	LoadFromDir("res://data/items/items/");
	LoadFromDir("res://data/items/key_items/");
	LoadFromDir("res://data/items/equipment/");
	LoadFromDir("res://data/items/spell_scrolls/");

	# Lists should already be sorted.
	# Items.Sort();
	# KeyItems.Sort();
	# SpellScrolls.Sort();
	# Equipment.Sort();
func LoadFromDir(path: String) -> void:
	print("Loading from directory: %s" % path);
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
			elif res is Item:
				items.append(res);
			else:
				print(" is not an item, skipping" % res);
				continue;

			res.update_id(next_id);
			next_id += 1

			var battleItem = res.battle_item; 
			if battleItem != null:
				battleItems.append(battleItem);
				if battleItem.IsConsumable:
					battleItem.ItemConsumed.connect(func(): QuantityChanged.emit(res, res.Quantity))
		elif len(item) != 0 and dir.dir_exists(item):
			LoadFromDir(path + item + "/");

func Add(item: Item) -> void:
	var list = []
	var cat = Category.Item;

	if item is Equipment:
		list = Equipment;
		cat = Category.Equipment;
	
	elif item is KeyItem:
		list = key_items;
		cat = Category.KeyItem;
	elif item is SpellScroll:
		list = spell_scrolls;
		cat = Category.SpellScroll;

	var index = list.binary_search(item);

	if list[index] == item:
		if list[index].TryCombine(item):
			QuantityChanged.emit(list[index], cat)
	else:
		list.Insert(index, item);
		QuantityChanged.emit(list[index], cat)

func Remove(item: Item, amount: int=-1) -> Item:
	var list = []
	var cat = Category.Item;
	if item is Equipment:
		list = equipment;
		cat = Category.Equipment;
	
	elif item is KeyItem:
		list = key_items;
		cat = Category.KeyItem;

	elif item is SpellScroll:
		list = spell_scrolls;
		cat = Category.SpellScroll;
	
	else: list = items;

	var index = list.BinarySearch(item);
	if list[index] == item:
		var output = list[index];
		list.remove_at(index);
		QuantityChanged.emit(output, cat)
		return output;
	return null;

