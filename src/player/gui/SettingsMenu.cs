using Godot;
using System;

public partial class SettingsMenu : Control {
	public void OnDebugModeToggled(bool val) {
		GD.Print("Debug mode toggled");
		Settings.Singleton.DebugMode = val;
	}
}
