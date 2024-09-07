using Godot;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

public partial class BattleGUI: Node
{
	[Signal]
	public delegate void ActionsSelectedEventHandler(ActorAction[] actions);
	[Signal]
	public delegate void BattleEndedEventHandler();

	[Export]
	private MessageBox messageBox;
	[Export]
	public TeamDisplay AllyDisplayParent { get; private set; }
	[Export]
	public TeamDisplay EnemyDisplayParent { get; private set; }
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
			AllyDisplayParent.AddDisplay(actor);
		}
		AllyDisplayParent.Highlight(0);
	}

	public void InitEnemies(BattleActor[] enemies) {
		this.enemies = enemies;
		foreach (BattleActor actor in enemies) {
			EnemyDisplayParent.AddDisplay(actor);
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
	public Vector2 GetActorDisplayPosition(int teamIndex, BattleActor actor=null) {
		TeamDisplay teamDisplay;
		if(teamIndex == 0) {
			teamDisplay = AllyDisplayParent;
		} else {
			teamDisplay = EnemyDisplayParent;
		}

		if(actor == null) {
			return teamDisplay.GlobalPosition;
		}

		BattleActorDisplay display = teamDisplay.GetDisplay(actor);
		return display.GetPosition();
	}
	public void EnablePlayerControls(bool enable) {
		playerControls.SetEnabled(enable);
	}

	public async void _on_action_selected(int index, BattleAction action) {
		BattleActor[] targets = await SelectTargets(allies[index], action);

		ActorAction actorAction = new(allies[index], action, targets, 0);
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
				if(AllyDisplayParent.Length == 1) {
					targets = new BattleActor[] { AllyDisplayParent.GetDisplay(0).Actor };
					// This pause is needed, otherwise the End turn button won't enable.
					var timer = GetTree().CreateTimer(.05);
					await ToSignal(timer, "timeout");
				} else {
					AllyDisplayParent.SelectTarget(false);
					target = (BattleActor)(await ToSignal(AllyDisplayParent, "Selected"))[0];
					targets = new BattleActor[] { target };
				}
				break;
			case BattleAction.TargetType.Allies:
				targets = allies;
				break;
			case BattleAction.TargetType.Enemy:
				if(EnemyDisplayParent.Length == 1) {
					targets = new BattleActor[] { EnemyDisplayParent.GetDisplay(0).Actor };
					// This pause is needed, otherwise the End turn button won't enable.
					var timer = GetTree().CreateTimer(.05);
					await ToSignal(timer, "timeout");
				} else {
					EnemyDisplayParent.SelectTarget(true);
					target = (BattleActor)(await ToSignal(EnemyDisplayParent, "Selected"))[0]; 
					targets = new BattleActor[] { target };
				}
				break;
			case BattleAction.TargetType.Enemies:
				targets = enemies;
				break;
		}

		return targets;
	}
	public void _on_active_actor_changed(int index) {
		AllyDisplayParent.Highlight(index);
	}
	public void _on_turn_ended(bool tryRunningAway) {
		if(tryRunningAway) {
			EmitSignal(SignalName.ActionsSelected, BattleAction.Flee);
		} else {
			EmitSignal(SignalName.ActionsSelected, selectedActions);
		}
	}
	public void _on_show_info(GodotObject action) {
		string msg = "Empty";
		if(action is BattleAction) {
			msg = $"{((BattleAction)action).Name}";
		} else if (action is BattleActor) {
			msg = $"{((BattleActor)action).ActorName}";
		}
		GD.Print(msg);
		
		DisplayMessageNonBlocking("", action);
	}
}
