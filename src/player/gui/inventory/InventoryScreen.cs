using Godot;
using Godot.Collections;
using System;

public partial class InventoryScreen : PanelContainer {
	[Export]
	private InventoryDisplayPanel infoPanel;
	[Export]
	private VBoxContainer itemsScroller;
	[Export]
	private VBoxContainer equipmentScroller;
	[Export]
	private VBoxContainer spellsScroller;
	[Export]
	private VBoxContainer keyItemsScroller;

	public void Setup(Inventory inventory) {
		var populateTab = (Array<Item> items, VBoxContainer scroller) => {
			foreach(Item item in items) {
				Button button = new();
				button.Text = $"{item.Name} ({item.Quantity})";
				var temp = item;
				button.Pressed += () => DisplayItemDetails(temp);
				scroller.AddChild(button);
			}
		};
		populateTab(inventory.Items, itemsScroller);
		populateTab(inventory.Equipment, equipmentScroller);
		populateTab(inventory.SpellScrolls, spellsScroller);
		populateTab(inventory.KeyItems, keyItemsScroller);
	}
	private void DisplayItemDetails(Item item) {
		GD.Print(item.Name);
	}

	private void OnItemAdded(Item item, Inventory.Category cat) {
	}
	private void OnItemRemoved(Item item, Inventory.Category cat) {
	}
}
