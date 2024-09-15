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

	private const string DISABLED_KEY = "disabled";

	[Export]
	private PackedScene threeStateButton;
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
	private BattleActor[] allies;

	public override void _Ready() {
		finalIndex = attacksPanel.GetChildCount() - 1;
		calc_character_selector_state(attacksPanel.CurrentTab);
	}
	public void Setup(BattleActor[] allies, BattleItem[] items, BattleActor[] enemies) {
		skipIndices = new();
		this.allies = allies;

		for(int i = 0; i < allies.Length; i++) {
			var ally = allies[i];
			PopulateNewAttackMenu(ally, i);
			skipIndices.Add(false);
			// Variable has to be set out here, otherwise it'll be passed by reference.
			var index = i;
			ally.Connect(BattleActor.SignalName.WasDefeated, Callable.From(() => {
				skipIndices[index] = true;
				// Recalc beginIndex and finalIndex.
				finalIndex = skipIndices.FindLastIndex((val) => !val);
				beginIndex = skipIndices.FindIndex((val) => !val);
				}));
			attacksPanel.Connect(TabContainer.SignalName.TabSelected, Callable.From((int tabIndex) => {
				if(tabIndex != index) return;
				// Disable/Enable attacks based on mana.
				for(int i = 0; i < ally.Attacks.Length; i++) {
					Attack attack = ally.Attacks[i];
					ThreeStateButton button = ((ThreeStateButton)attacksPanel.GetChild(index).GetChild(0).GetChild(i));
					button.IsLocked = !attack.IsActionAvailable(ally);
				}
				// Disable/Enable items based on reqs.
				for(int i = 0; i < items.Length; i++) {
					BattleItem item = items[i];
					ThreeStateButton button = ((ThreeStateButton)itemsScroller.GetChild(i));
					button.IsLocked = item.IsActionAvailable(ally);
				}
			}));
		}
		PopulateItemsMenu(items);
		PopulateCharactersMenu(allies, enemies);

		finalIndex = attacksPanel.GetChildCount() - 1;
		// Doing this activates the "check if available" method.
		attacksPanel.CurrentTab = attacksPanel.CurrentTab;
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
			ThreeStateButton button = threeStateButton.Instantiate<ThreeStateButton>();
			button.ButtonGroup = group;
			button.Text = attack.Name;
			button.Connect(ThreeStateButton.SignalName.StateChanged, Callable.From((int state) => { 
				OnActionSelected(state, index, attack); 
			}));
			Connect(SignalName.EndTurn, Callable.From((bool _) => {
				button.Reset();
			}));
			vbox.AddChild(button);
		}
		attacksPanel.AddChild(scroller);
	}
	private void PopulateItemsMenu(BattleItem[] items) {
		ButtonGroup group = new();

		foreach(BattleItem item in items) {
			ThreeStateButton button = threeStateButton.Instantiate<ThreeStateButton>();
			button.ButtonGroup = group;
			button.Text = item.Name;
			button.Connect(ThreeStateButton.SignalName.StateChanged, Callable.From((int state) => { OnActionSelected(state, attacksPanel.CurrentTab, item); }));

			Connect(SignalName.EndTurn, Callable.From((bool _) => {
				button.Reset();
			}));
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
			button.Connect(Button.SignalName.Pressed, Callable.From(() => {
				EmitSignal(SignalName.ShowInfo, ally);	
			}));

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
			button.Connect(Button.SignalName.Pressed, Callable.From(() => {
				EmitSignal(SignalName.ShowInfo, enemy);	
			}));

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
	private void OnActionSelected(int state, int index, BattleAction action) {
		if(state == ThreeStateButton.FIRST_SELECTED_STATE) {
			EmitSignal(SignalName.ShowInfo, action);	
		} 
		switch(state) {
			case ThreeStateButton.FIRST_SELECTED_STATE:
				EmitSignal(SignalName.ShowInfo, action);	
				break;
			case ThreeStateButton.SECOND_SELECTED_STATE:
				EmitSignal(SignalName.ActionSelected, index, action);
				allowEndTurn = edgeIndex >= finalIndex;
				break;
			default:
				break;
		}
	}
}
