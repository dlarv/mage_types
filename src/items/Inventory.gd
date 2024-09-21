using Godot;
using System;
using Godot.Collections;

[Tool]
[GlobalClass]
public partial class Inventory : Node {
	public enum Category { Item, Equipment, SpellScroll, KeyItem }

	// NOTE: This is not called when loading from filesystem.
	[Signal]
	public delegate void QuantityChangedEventHandler(Item item, int amount);

	[Export]
	public Array<Item> Items { get; private set; } = new();
	[Export]
	public Array<Item> Equipment {get; private set; } = new();
	[Export]
	public Array<Item> SpellScrolls {get; private set; } = new();
	[Export]
	public Array<Item> KeyItems {get; private set; } = new();

	// Secondary reference to battle items.
	private Array<BattleItem> battleItems = new();

	public override void _EnterTree() {
		LoadFromFS();
	}

	public Array<BattleItem> GetBattleItems() {
		return battleItems;
	}

	public Item[] Search(string term) {
		return null;
	}

	public void LoadFromFS() {
		Item.ResetIds();

		Items = new();
		KeyItems = new();
		SpellScrolls = new();
		Equipment = new();
		battleItems = new();

		LoadFromDir("res://data/items/items/");
		LoadFromDir("res://data/items/key_items/");
		LoadFromDir("res://data/items/equipment/");
		LoadFromDir("res://data/items/spell_scrolls/");

		// Lists should already be sorted.
		// Items.Sort();
		// KeyItems.Sort();
		// SpellScrolls.Sort();
		// Equipment.Sort();
	}
	private void LoadFromDir(string path) {
		GD.Print($"Loading from directory: {path}");
		DirAccess dir = DirAccess.Open(path);
		string item = "temp";

		dir.ListDirBegin();
		while(len(item) != 0 && dir != null) {
			item = dir.GetNext();

			if(dir.FileExists(item)) {
				if(!item.EndsWith(".tres")) continue;

				Resource res = GD.Load(path + item);
				if(res == null) continue;
				if(res is Equipment) {
					Equipment.Add((Equipment)res);
				}
				else if(res is KeyItem) {
					KeyItems.Add((KeyItem)res);
				}
				else if(res is SpellScroll) {
					SpellScrolls.Add((SpellScroll)res);
				}
				else if(res is Item) {
					Items.Add((Item)res);
				} else {
					GD.Print($"{res} is not an item, skipping");
					continue;
				}
				Item itemObj = (Item)res;
				itemObj.UpdateId();

				BattleItem battleItem = itemObj.BattleItem; 
				if(battleItem != null) {
					battleItems.Add(battleItem);
					if(battleItem.IsConsumable) {
						battleItem.Connect(
								BattleItem.SignalName.ItemConsumed, 
								Callable.From(() => EmitSignal(
										SignalName.QuantityChanged, 
										itemObj, 
										itemObj.Quantity)));
					}
				}
			} 
			else if(len(item) != 0 && dir.DirExists(item)) {
				LoadFromDir(path + item + "/");
			}
		}
	}

	public void Add(Item item) {
		Array<Item> list = new();
		Category cat = Category.Item;
		if(item is Equipment) {
			list = Equipment;
			cat = Category.Equipment;
		}
		else if(item is KeyItem) {
			list = KeyItems;
			cat = Category.KeyItem;
		}
		else if(item is SpellScroll) {
			list = SpellScrolls;
			cat = Category.SpellScroll;
		}

		int index = list.BinarySearch(item);
		if(list[index] == item) {
			if(list[index].TryCombine(item)) {
				EmitSignal(SignalName.QuantityChanged, list[index], (int)cat);
			}
		} else {
			list.Insert(index, item);
			EmitSignal(SignalName.QuantityChanged, item, (int)cat);
		}
	}
	public Item Remove(Item item, int amount=-1) {
		Array<Item> list = new();
		Category cat = Category.Item;
		if(item is Equipment) {
			list = Equipment;
			cat = Category.Equipment;
		}
		else if(item is KeyItem) {
			list = KeyItems;
			cat = Category.KeyItem;
		}
		else if(item is SpellScroll) {
			list = SpellScrolls;
			cat = Category.SpellScroll;
		}
		else list = Items;

		int index = list.BinarySearch(item);
		if(list[index] == item) {
			Item output = list[index];
			list.RemoveAt(index);
			EmitSignal(SignalName.QuantityChanged, output, ((int)cat));
			return output;
		}
		return null;
	}
	
}
