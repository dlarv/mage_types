using Godot;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

public partial class BattleGUI: Node
{
	[Signal]
	public delegate void ActionsSelectedEventHandler(BattleAction[] actions);
	[Signal]
	public delegate void BattleEndedEventHandler();

	[Export]
	private MessageBox messageBox;
	[Export]
	private TeamDisplay allyDisplayParent;
	[Export]
	private TeamDisplay enemyDisplayParent;
	[Export]
	private PlayerControls playerControls;

	protected BattleActor[] allies;
	protected BattleActor[] enemies;
	private List<string> messages = new();
	private ActorAction[] selectedActions;

	public void Setup(BattleActor[] allies, BattleItem[] items, BattleActor[] enemies) {
		InitAllies(allies);
		InitEnemies(enemies);
		AddItemsToInventory(items);
		playerControls.Setup(allies, items, enemies);
	}

	public void InitAllies(BattleActor[] allies) {
		this.allies = allies;
		selectedActions = new ActorAction[allies.Length];

		foreach (BattleActor actor in allies) {
			allyDisplayParent.AddDisplay(actor);
		}
		allyDisplayParent.Highlight(0);
	}

	public void InitEnemies(BattleActor[] enemies) {
		this.enemies = enemies;
		foreach (BattleActor actor in enemies) {
			enemyDisplayParent.AddDisplay(actor);
		}
	}

	private void AddItemsToInventory(BattleItem[] items) {
	}

	public void PlayAnimation(PackedScene animation, Vector2 start, Vector2 end) {
	}

	public async Task DisplayMessage(string msg) {
		messages.Add(msg);
		await messageBox.DisplayMessageBlocking(msg);
	}
	public void DisplayMessageNonBlocking(string msg, GodotObject obj=null) {
		messages.Add(msg);
		messageBox.DisplayMessageNonBlocking(msg, obj);
	}

	public void AddStatusEffect(StatusEffect effect, BattleActor target) {
	}

	public void RemoveStatusEffect(StatusEffect effect, BattleActor target) {
	}

	public void ChangeHealth(int newHealth, BattleActor target) {
	}

	public void RemoveActor(BattleActor target) {
	}

	public async void _on_action_selected(int index, BattleAction action) {
		BattleActor[] targets = await SelectTargets(allies[index], action);

		ActorAction actorAction = new(allies[index], action, targets);
		selectedActions[index] = actorAction;
		messageBox.Clear();
		playerControls.NextCharacter();
	}
	private async Task<BattleActor[]> SelectTargets(BattleActor user, BattleAction action) {
		BattleActor[] targets = null;
		BattleActor target;
		switch(action.Target) {
			case BattleAction.TargetType.Self:
				targets = new BattleActor[] { user };
				break;
			case BattleAction.TargetType.Ally:
				allyDisplayParent.SelectTarget(false);
				target = (BattleActor)(await ToSignal(allyDisplayParent, "Selected"))[0];
				targets = new BattleActor[] { target };
				break;
			case BattleAction.TargetType.Allies:
				targets = allies;
				break;
			case BattleAction.TargetType.Enemy:
				enemyDisplayParent.SelectTarget(true);
				target = (BattleActor)(await ToSignal(enemyDisplayParent, "Selected"))[0]; 
				targets = new BattleActor[] { target };
				break;
			case BattleAction.TargetType.Enemies:
				targets = enemies;
				break;
		}

		return targets;
	}
	public void _on_active_actor_changed(int index) {
		allyDisplayParent.Highlight(index);
	}
	public void _on_turn_ended(bool tryRunningAway) {
		if(tryRunningAway) {
			EmitSignal(SignalName.ActionsSelected, BattleAction.Flee);
		} else {
			EmitSignal(SignalName.ActionsSelected, selectedActions);
		}
	}
	public void _on_show_info(BattleAction action) {
		string msg = $"{action.Name}";
		GD.Print(msg);
		DisplayMessageNonBlocking("", action);
	}
}
