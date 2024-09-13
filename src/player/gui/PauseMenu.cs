using Godot;
using System;

public partial class PauseMenu : Control {
	[Export]
	public InventoryScreen inventoryScreen;

	public void InitInventory(Inventory inventory) {
		inventoryScreen.Setup(inventory);
	}
}
