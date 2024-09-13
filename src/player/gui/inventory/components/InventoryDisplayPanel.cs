using Godot;
using System;

public partial class InventoryDisplayPanel : Control {
	public void Display(Item item) {
		if(item is Equipment) FormatEquipment((Equipment)item);
		else if(item is KeyItem) FormatKeyItem((KeyItem)item);
		else if(item is SpellScroll) FormatSpellScroll((SpellScroll)item);
		else if(item is Item) FormatItem(item);
	}

	private void FormatEquipment(Equipment item) { }
	private void FormatKeyItem(KeyItem item) { }
	private void FormatSpellScroll(SpellScroll item) { }
	private void FormatItem(Item item) { }
}
