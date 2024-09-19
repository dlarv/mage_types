using Godot;
using System;

[GlobalClass]
public partial class PauseMenu : Control {
	[Export]
	private InventoryScreen inventoryScreen;
	[Export]
	private Node3D world;

	public void InitInventory(Inventory inventory) {
		inventoryScreen.Setup(inventory);
	}

	public override void _UnhandledInput(InputEvent @event) {
		if(@event.IsActionPressed("open_pause_menu")) {
			Visible = !Visible;
			world.ProcessMode = !Visible ? ProcessModeEnum.Inherit : ProcessModeEnum.Disabled;
		}
	}
}
