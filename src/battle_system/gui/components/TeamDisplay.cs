using Godot;
using System;
using System.Collections.Generic;

[Tool]
public partial class TeamDisplay : Control
{
	[Signal]
	public delegate void SelectedEventHandler(BattleActor actor, int i);

	[Export]
	private PackedScene displayPrefab;
	[Export]
	private HBoxContainer displayParent;
	private bool _shiftRight;
	[Export]
	public bool ShiftRight { 
		get => _shiftRight; 
		set {
			_shiftRight = value;
			if (displayParent == null) return;
			if(value) {
				displayParent.Alignment = BoxContainer.AlignmentMode.End;
			} else {
				displayParent.Alignment = BoxContainer.AlignmentMode.Begin;
			}
		}
	}
	private List<BattleActorDisplay> displays = new();
	private int highlightedActorIndex = 0;

	public void AddDisplay(BattleActor actor) {
		/*BattleActorDisplay display = new BattleActorDisplay(actor);*/
		BattleActorDisplay display = displayPrefab.Instantiate<BattleActorDisplay>();
		display.Setup(actor);
		displays.Add(display);
		displayParent.AddChild(display);
		display.Selected += (BattleActor actor) => {
			EmitSignal(SignalName.Selected, actor, 11);
			foreach(BattleActorDisplay display in displays) {
				display.DisableSelection();
			}
		};
	}

	public BattleActorDisplay GetDisplay(int index) {
		if(index < displays.Count) {
			return displays[index];
		}
		return null;
	}

	public void SelectTarget(bool isAttack) {
		Color highlight = isAttack ? Colors.Red : Colors.Green;
		foreach(BattleActorDisplay display in displays) {
			display.EnableSelection(highlight);
		}
	}

	// Highlight the display of the currently active actor.
	public void Highlight(int index) {
		displays[highlightedActorIndex].SetHighlight(false);
		highlightedActorIndex = index;
		displays[highlightedActorIndex].SetHighlight(true);
	}
}
