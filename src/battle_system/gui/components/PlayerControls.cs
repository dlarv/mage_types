using Godot;
using System;

public partial class PlayerControls : PanelContainer
{
	[Signal]
	public delegate void ActionSelectedEventHandler(int index, BattleAction action);
	[Signal]
	public delegate void EndTurnEventHandler(bool tryRunAway);
	[Signal]
	public delegate void ShowInfoEventHandler(BattleAction action);
	[Signal]
	public delegate void ActiveActorChangedEventHandler(int index);

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

	// The index of the rightmost character who has selected an action.
	private int edgeIndex = 0;
	private int finalIndex = 0;
	private bool allowEndTurn = false;

	public override void _Ready() {
		finalIndex = attacksPanel.GetChildCount() - 1;
		calc_character_selector_state(attacksPanel.CurrentTab);
	}
	public void Setup(BattleActor[] allies, BattleItem[] items, BattleActor[] enemies) {
		for(int i = 0; i < allies.Length; i++) {
			PopulateNewAttackMenu(allies[i], i);
		}
		PopulateItemsMenu(items);
		// Populate characters
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

	public void PrevCharacter() {
		controlPanel.CurrentTab = 0;
		int index = attacksPanel.CurrentTab;
		index = Math.Max(index - 1, 0);
		attacksPanel.CurrentTab = index;

		EmitSignal(SignalName.ActiveActorChanged, index);
		calc_character_selector_state(index);
	}
	public void NextCharacter() {
		controlPanel.CurrentTab = 0;
		int index = attacksPanel.CurrentTab;
		/*index = Math.Min(index, finalIndex + 1);*/
		index = Math.Min(index + 1, finalIndex);
		attacksPanel.CurrentTab = index;

		edgeIndex = Math.Max(index, edgeIndex);

		EmitSignal(SignalName.ActiveActorChanged, index);
		calc_character_selector_state(index);
	}
	public void _on_start_button_pressed() {
		controlPanel.CurrentTab = 0;
		allowEndTurn = false;
		EmitSignal(SignalName.EndTurn, false);
	}
	private void calc_character_selector_state(int index) {
		prevButton.Disabled = index == 0;
		nextButton.Disabled = index == edgeIndex;
		/*endButton.Disabled = edgeIndex < finalIndex;*/
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
			return;
		}
		if(meta) {
			EmitSignal(SignalName.ActionSelected, index, action);
			allowEndTurn = edgeIndex == finalIndex;
		} else {
			EmitSignal(SignalName.ShowInfo, action);	
			button.SetMeta(KEY, true);
		}
	}
}
