using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;

public partial class PlayerControls : PanelContainer
{
	[Signal]
	public delegate void ActionSelectedEventHandler(int index, GodotObject action);
	[Signal]
	public delegate void EndTurnEventHandler(bool tryRunAway);
	[Signal]
	public delegate void ShowInfoEventHandler(BattleAction action);
	[Signal]
	public delegate void ActiveActorChangedEventHandler(int index);

	[Export]
	private Color targetingHoverColor;
	[Export]
	private TabContainer controlPanel;
	[Export]
	private TabContainer attacksPanel;
	[Export]
	private VBoxContainer itemsScroller;
	[Export]
	private VBoxContainer characterScroller;
	[Export]
	private Button nextButton;
	[Export]
	private Button prevButton;
	[Export]
	private Button endButton;
	[Export]
	private Panel blockingPanel;

	// The index of the rightmost character who has selected an action.
	private int edgeIndex = 0;
	// Index to reset to when a new turn is begun.
	private int beginIndex = 0;
	private int finalIndex = 0;
	private bool allowEndTurn = false;
	// List of indices of defeated actors.
	private List<bool> skipIndices;

	public override void _Ready() {
		finalIndex = attacksPanel.GetChildCount() - 1;
		calc_character_selector_state(attacksPanel.CurrentTab);
	}
	public void Setup(BattleActor[] allies, BattleItem[] items, BattleActor[] enemies) {
		skipIndices = new();

		for(int i = 0; i < allies.Length; i++) {
			var ally = allies[i];
			PopulateNewAttackMenu(ally, i);
			skipIndices.Add(false);
			// Variable has to be set out here, otherwise it'll be passed by reference.
			var index = i;
			ally.WasDefeated += () => {
				skipIndices[index] = true;
				// Recalc beginIndex and finalIndex.
				finalIndex = skipIndices.FindLastIndex((val) => !val);
				beginIndex = skipIndices.FindIndex((val) => !val);
			};
		}
		PopulateItemsMenu(items);
		PopulateCharactersMenu(allies, enemies);

		finalIndex = attacksPanel.GetChildCount() - 1;
		calc_character_selector_state(attacksPanel.CurrentTab);
	}
	private void PopulateNewAttackMenu(BattleActor actor, int index) {
		ScrollContainer scroller = new();
		VBoxContainer vbox = new();
		ButtonGroup group = new();
		vbox.SizeFlagsHorizontal = SizeFlags.ExpandFill;
		vbox.SizeFlagsVertical = SizeFlags.ExpandFill;
		scroller.AddChild(vbox);

		foreach(Attack attack in actor.Attacks) {
			Button button = new();
			button.ToggleMode = true;
			button.ButtonGroup = group;
			button.SizeFlagsHorizontal = SizeFlags.ExpandFill;
			button.Text = attack.Name;
			button.Toggled += (toggled) => OnActionSelected(button, toggled, index, attack);
			vbox.AddChild(button);
		}
		attacksPanel.AddChild(scroller);
	}
	private void PopulateItemsMenu(BattleItem[] items) {
		ButtonGroup group = new();

		foreach(BattleItem item in items) {
			Button button = new();
			button.ToggleMode = true;
			button.ButtonGroup = group;
			button.SizeFlagsHorizontal = SizeFlags.ExpandFill;
			button.SizeFlagsVertical = SizeFlags.ExpandFill;
			button.Text = item.Name;
			button.Toggled += (toggled) => OnActionSelected(button, toggled, attacksPanel.CurrentTab, item);
			itemsScroller.AddChild(button);
		}
	}
	private void PopulateCharactersMenu(BattleActor[] allies, BattleActor[] enemies) {
		ButtonGroup group = new();

		Label label = new();
		label.Text = "Allies";
		characterScroller.AddChild(label);
		foreach(BattleActor ally in allies) {
			Button button = new();
			button.ButtonGroup = group;
			button.SizeFlagsHorizontal = SizeFlags.ExpandFill;
			button.SizeFlagsVertical = SizeFlags.ExpandFill;
			button.Text = ally.ActorName;
			button.Pressed += () => {
				EmitSignal(SignalName.ShowInfo, ally);	
			};

			characterScroller.AddChild(button);
		}

		label = new();
		label.Text = "Enemies";
		characterScroller.AddChild(label);
		foreach(BattleActor enemy in enemies) {
			Button button = new();
			button.ButtonGroup = group;
			button.SizeFlagsHorizontal = SizeFlags.ExpandFill;
			button.SizeFlagsVertical = SizeFlags.ExpandFill;
			button.Text = enemy.ActorName;
			button.Pressed += () => {
				EmitSignal(SignalName.ShowInfo, enemy);	
			};

			characterScroller.AddChild(button);
		}
	}

	public void PrevCharacter() {
		controlPanel.CurrentTab = 0;
		int index = attacksPanel.CurrentTab;
		for(int i = 1; index - i >= beginIndex - 1; i++) {
			index = Math.Max(index - i, beginIndex);
			if(!skipIndices[index]) break;
		}
		attacksPanel.CurrentTab = index;

		EmitSignal(SignalName.ActiveActorChanged, index);
		calc_character_selector_state(index);
	}
	public void NextCharacter() {
		controlPanel.CurrentTab = 0;

		int index = attacksPanel.CurrentTab;
		for(int i = 1; index + i <= finalIndex + 1; i++) {
			index = Math.Min(index + i, finalIndex);
			if(!skipIndices[index]) break;
		}

		attacksPanel.CurrentTab = index;

		edgeIndex = Math.Max(index, edgeIndex);

		EmitSignal(SignalName.ActiveActorChanged, index);
		calc_character_selector_state(index);
	}
	public void SetEnabled(bool enable) {
		blockingPanel.Visible = !enable;
		if(enable) {
			attacksPanel.CurrentTab = beginIndex;
			edgeIndex = beginIndex;
			calc_character_selector_state(beginIndex);
			EmitSignal(SignalName.ActiveActorChanged, beginIndex);
		}
	}
	public void _on_end_turn_button_pressed() {
		controlPanel.CurrentTab = 0;
		allowEndTurn = false;
		EmitSignal(SignalName.EndTurn, false);
	}
	private void calc_character_selector_state(int index) {
		prevButton.Disabled = index == beginIndex;
		nextButton.Disabled = index == edgeIndex;
		endButton.Disabled = !allowEndTurn;
	}
	public void _on_attacks_button_pressed() {
		controlPanel.CurrentTab = 1;
	}
	public void _on_items_button_pressed() {
		controlPanel.CurrentTab = 2;
	}
	public void _on_characters_button_pressed() {
		controlPanel.CurrentTab = 3;
	}
	public void _on_run_button_pressed() {
		EmitSignal(SignalName.EndTurn, true);
	}
	public void _on_back_button_pressed() {
		controlPanel.CurrentTab = 0;
	}
	private void OnActionSelected(Button button, bool toggled, int index, BattleAction action) {
		const string KEY = "is_selected";
		bool meta = (bool)button.GetMeta(KEY, false);

		if(!toggled) {
			button.SetMeta(KEY, false);
			button.SelfModulate = Colors.White;
			return;
		}
		if(meta) {
			EmitSignal(SignalName.ActionSelected, index, action);
			allowEndTurn = edgeIndex >= finalIndex;
			button.SelfModulate = targetingHoverColor;
		} else {
			EmitSignal(SignalName.ShowInfo, action);	
			button.SetMeta(KEY, true);
			button.SelfModulate = Colors.White;
		}
	}
}
