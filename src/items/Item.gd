using Godot;
using Godot.Collections;
using System;

[Tool]
[GlobalClass]
public partial class Item : Resource, IComparable<Item> {
	private static int nextId = 0;

	public int Id { get; private set; }
	[Export]
	public string Name { 
		get => _name; 
		set {
			_name = value;
			if(BattleItem != null) {
				BattleItem.Name = value;
			}
		}
	}
	private string _name;
	[Export]
	public BattleItem BattleItem { get; set; }
	[Export]
	public bool IsConsumable { 
		get => _isConsumable; 
		set {
			_isConsumable = value;
			if(BattleItem != null) {
				BattleItem.IsConsumable = value;
			}
		}
	}
	private bool _isConsumable;
	[Export]
	public int Quantity { 
		get {
			if(BattleItem != null) {
				return BattleItem.Quantity;
			}
			else {
				return _quantity; 
			}
		}
		set {
			_quantity = value;
			if(BattleItem != null) {
				BattleItem.Quantity = value;
			}
		}
	}
	private int _quantity;
	[Export]
	public int MaxQuantity { get; set; }
	[Export]
	public ItemRequirement Requirement { 
		get => _reqs; 
		set {
			_reqs = value;
			if(BattleItem != null && value != null && value.BattleRelevant) {
				BattleItem.Requirement = value;
			}
		}
	}
	private ItemRequirement _reqs;
	[Export]
	public Array<string> Tags { get; set; }
	[Export(PropertyHint.MultilineText)]
	public string Details { 
		get => _details;
		set {
			_details = value;
			if(BattleItem != null) {
				BattleItem.Details = value;
			}
		}
	}
	private string _details;

	public void UpdateId() {
		Id = nextId;
		nextId++;
	}
	public static void ResetIds() {
		nextId = 0;
	}


	public bool TryCombine(Item other) {
		if(Quantity == MaxQuantity) return false;
		if(MaxQuantity == -1) {
			Quantity += other.Quantity;
			return true;
		}

		int total = Quantity + other.Quantity;
		Quantity = Math.Min(total, MaxQuantity);
		return true;
	}
	public bool TryRemove(Item other, int amount) {
		if(Quantity == 0) return false;
		if(amount == -1) amount = Quantity;

		int total = Quantity - amount;
		Quantity = Math.Max(0, total);
		return true;
	}

	public int CompareTo(Item other) {
		return this.Id.CompareTo(other.Id);
	}
}
