using Godot;
using System;

[GlobalClass]
public partial class BattleItem : BattleAction
{
	public static BattleItem Create(string name, string details="") {
		BattleItem item = new();
		item.Name = name;
		item.Details = details;
		return item;
	}
}
