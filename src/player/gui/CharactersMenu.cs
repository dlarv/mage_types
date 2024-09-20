using Godot;
using System;

public partial class CharactersMenu : Control {
	[Export]
	private TabContainer activeScreensParent;
	[Export]
	private Control inactiveScreensParent;

	[Export]
	private CharacterScreen aliceScreen;
	[Export]
	private CharacterScreen alexScreen;

	[Export]
	private int statsToDistribute = 0;
}
