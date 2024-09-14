using Godot;
using System;
using System.Collections.Generic;

[Tool]
public partial class TeamDisplay : Control
{
	[Signal]
	public delegate void SelectedEventHandler(BattleActor actor, int i);
	[Signal]
	public delegate void StatusEffectIconPressedEventHandler(StatusEffect effect);

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
	public int Length { get => displays.Count; }
	private List<BattleActorDisplay> displays = new();
	private int highlightedActorIndex = 0;

	public void AddDisplay(BattleActor actor) {
		BattleActorDisplay display = displayPrefab.Instantiate<BattleActorDisplay>();
		display.Setup(actor);
		displays.Add(display);
		displayParent.AddChild(display);
		display.Connect(BattleActorDisplay.SignalName.Selected, Callable.From((BattleActor actor) => {
			EmitSignal(SignalName.Selected, actor, 11);
			foreach(BattleActorDisplay display in displays) {
				display.DisableSelection();
			}
		}));
		display.Connect(BattleActorDisplay.SignalName.StatusEffectIconPressed, Callable.From((StatusEffect effect) => EmitSignal(SignalName.StatusEffectIconPressed, effect)));
	}

	public BattleActorDisplay GetDisplay(int index) {
		if(index < displays.Count) {
			return displays[index];
		}
		return null;
	}

	public BattleActorDisplay GetDisplay(BattleActor actor) {
		foreach(BattleActorDisplay display in displays) {
			if(display.Actor == actor) {
				return display;
			}
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
