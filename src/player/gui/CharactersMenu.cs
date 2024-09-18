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
	public bool IsAliceActive {
		get => _isAliceActive;
		set {
			_isAliceActive = value;
			if(inactiveScreensParent == null) inactiveScreensParent = GetNode<Control>("InactiveTabs");
			if(activeScreensParent == null) activeScreensParent = GetNode<TabContainer>("MarginContainer/ActiveTabs");

			if(value) {
				Node screen = inactiveScreensParent.GetNode("Alice");

				if(screen == null) return;
				inactiveScreensParent.RemoveChild(screen);
				activeScreensParent.AddChild(screen);
				activeScreensParent.MoveChild(screen, 1);
			} else {
				Node screen = activeScreensParent.GetNode("Alice");

				if(screen == null) return;
				activeScreensParent.RemoveChild(screen);
				inactiveScreensParent.AddChild(screen);
			}
		}
	}
	private bool _isAliceActive = true;
	[Export]
	public bool IsAlexActive {
		get => _isAlexActive;
		set {
			_isAlexActive = value;
			if(inactiveScreensParent == null) inactiveScreensParent = GetNode<Control>("InactiveTabs");
			if(activeScreensParent == null) activeScreensParent = GetNode<TabContainer>("MarginContainer/ActiveTabs");

			if(value) {
				Node screen = inactiveScreensParent.GetNode("Alex");
				if(screen == null) return;
				inactiveScreensParent.RemoveChild(screen);
				activeScreensParent.AddChild(screen);
				activeScreensParent.MoveChild(screen, 1);
			} else {
				Node screen = activeScreensParent.GetNode("Alex");
				if(screen == null) return;
				activeScreensParent.RemoveChild(screen);
				inactiveScreensParent.AddChild(screen);
			}
		}
	}
	private bool _isAlexActive = true;
	[Export]
	private int statsToDistribute = 0;
}
