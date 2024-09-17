using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

[GlobalClass]
public partial class Battle : Node
{
	[Signal]
	public delegate void BattleEndedEventHandler();

	private BattleActor[] enemies;
	private BattleActor[] allies;
	private BattleActor[] actors;
	[Export]
	private BattleGUI gui;
	[Export]
	private OpponentController ai;
	[Export]
	private CanvasLayer matchupManager;
	
	private int defeatedAllies = 0;
	private int defeatedEnemies = 0;

	public override void _UnhandledInput(InputEvent @event) {
		if(@event.IsActionPressed("open_pause_menu")) {
			matchupManager.Visible = !matchupManager.Visible;
		}
	}

	public void Start(BattleActor[] allies, BattleItem[] allyItems, BattleActor[] enemies, OpponentController ai) {
		this.allies = allies;
		this.enemies = enemies;
		this.actors = allies.Concat(enemies).ToArray();
		/*this.ai = ai;*/

		foreach(BattleActor ally in allies) {
			ally.Connect(BattleActor.SignalName.WasDefeated, Callable.From(() => defeatedAllies++));
		}
		foreach(BattleActor enemy in enemies) {
			enemy.Connect(BattleActor.SignalName.WasDefeated, Callable.From(() => defeatedEnemies++));
		}

		gui.Setup(allies, allyItems, enemies);
	}

	public async void OnPlayerActionsSelected(ActorAction[] allyActions) {
		// If allyActions is empty, the player pressed the "Run" button.
		if(allyActions.Length == 0) {
			await gui.DisplayMessage("You ran away.");
			EmitSignal(SignalName.BattleEnded);
			return;
		}

		gui.EnablePlayerControls(false);
		ActorAction[] enemyActions = ai.GetActions(enemies, allies);
		List<ActorAction> actions = allyActions.Concat(enemyActions).ToList<ActorAction>();

		// Calculate turn order based on priority and actor speed.
		actions.Sort();

		// Calculate side effects and abilities.
		foreach(BattleActor actor in allies.Concat(enemies)) {
		}

		foreach(ActorAction action in actions) {
			// This means a character is defeated or flinched.
			if(action == null) {
				continue;
			}

			if(action.actor.Flinching) {
				continue;
			}
			action.action.ApplyCost(action.actor);

			// Play animation.
			Vector2 userPosition = gui.GetActorDisplayPosition(action.teamIndex, action.actor);
			int targetTeamIndex;
			TeamDisplay teamDisplay;
			// Target same team as user.
			if(action.action.Target == BattleAction.TargetType.Self 
					|| action.action.Target == BattleAction.TargetType.Ally
					|| action.action.Target == BattleAction.TargetType.Allies) {
				targetTeamIndex = action.teamIndex;
				teamDisplay = action.teamIndex == 0 ? gui.AllyDisplayParent : gui.EnemyDisplayParent;
			// Target opposite team from user.
			} else {
				targetTeamIndex = (action.teamIndex + 1) % 2;
				teamDisplay = action.teamIndex == 1 ? gui.AllyDisplayParent : gui.EnemyDisplayParent;
			}
			Vector2 targetPosition = gui.GetActorDisplayPosition(
					targetTeamIndex, 
					action.targets.Length == 1 ? action.targets[0] : null
					);
			
			Node animation = action.action.PlayAnimation(userPosition, targetPosition);
			AddChild(animation);

			// Apply action effects.
			string msg = action.action.ApplyEffects(action.actor, action.targets);

			// Display message and await input.
			await gui.DisplayMessage(msg);

			// Calculate target transmutations.
			foreach(BattleActor target in action.targets) {
				await CalculateTransmutations(target, action.action);
			}
			// Calculate user transmutations.
			// If the user targeted themselves using this attack, these calculations were already done.
			// (e.g. Target = Allies || Self || Ally).
			// This only applies to melee attacks.
			if(!action.targets.Contains(action.actor) 
					&& action.action is Attack 
					&& ((Attack)action.action).Range == Attack.AttackRange.Melee) {
				await CalculateTransmutations(action.actor, action.action); 
			}

			// Resolve user's status effects.
			msg = action.actor.ResolveEndOfTurn();		
			if(msg.Length > 0) {
				/*teamDisplay = action.teamIndex == 0 ? gui.AllyDisplayParent : gui.EnemyDisplayParent;*/
				/*teamDisplay.GetDisplay(action.actor).SetHealth(action.actor.CurrentHp);*/
				await gui.DisplayMessage(msg);
			}

			// Check if battle should end.
			if(defeatedAllies == allies.Length) {
				await gui.DisplayMessage("You were defeated...");
				EmitSignal(SignalName.BattleEnded);
			} else if(defeatedEnemies == enemies.Length) {
				await gui.DisplayMessage("You won!");
				EmitSignal(SignalName.BattleEnded);
			}
			// Pause before processing next turn.
			var timer = GetTree().CreateTimer(.5);
			await ToSignal(timer, "timeout");
		}
		gui.EnablePlayerControls(true);
	}

	public async Task CalculateTransmutations(BattleActor target, BattleAction action) {
		string msg = "";
		string e1 = target.Element1.Name.ToLower();
		string e2 = target.Element2.Name.ToLower();
		string ea = action.Element.Name.ToLower();

		// Calculate primary + attack 
		ElementalType newType = ElementManager.GetMatchup(target.Element1, action.Element);
		if(newType != null) {
			msg += $"The target {target.ActorName}'s [color={e1}]{e1}[/color] reacted with the attack's [color={ea}]{ea}[/color] type to make [color={newType.Name.ToLower()}]{newType.Name.ToLower()}[/color].\n";
			(AttackEffect buff, AttackEffect debuff) = ElementManager.GetSideEffect(
					target.Element1, action.Element);
			if(buff != null) {
				msg += $"\nThis reaction had side effects! "
				+ $"{target.ActorName} received {buff.ApplyEffect(target)}";
			}
			if(debuff != null) {
				msg += $"\nThis reaction had side effects! "
				+ $"{target.ActorName} received {debuff.ApplyEffect(target)}";
			}

			string msg2 = target.SetElement(0, newType);
			if(msg2.Length > 0) {
				msg += $"\n{msg2}";
			}
		}

		// Calculate secondary + attack 
		newType = ElementManager.GetMatchup(target.Element2, action.Element);
		if(newType != null && !target.InStasis) {
			msg += $"The target {target.ActorName}'s [color={e2}]{e2}[/color] reacted with the attack's [color={ea}]{ea}[/color] type to make [color={newType.Name.ToLower()}]{newType.Name.ToLower()}[/color].";


			(AttackEffect buff, AttackEffect debuff) = ElementManager.GetSideEffect(
					target.Element2, action.Element);
			if(buff != null) {
				msg += $"\nThis reaction had side effects! " 
				+ $"{target.ActorName} received {buff.ApplyEffect(target)}";
			}
			if(debuff != null) {
				msg += $"\nThis reaction had side effects! " 
					+ $"{target.ActorName} received {debuff.ApplyEffect(target)}";
			}
			string msg2 = target.SetElement(1, newType);
			if(msg2.Length > 0) {
				msg += $"\n{msg2}";
			}
		}

		// Only display message if applicable.
		// If no changes occurred, iteration can end here.
		if(msg.Length > 0) {
			await gui.DisplayMessage(msg);
		} else return;

		// Calculate primary + secondary.
		newType = ElementManager.GetMatchup(target.Element1, target.Element2);
		if(newType != null && !target.Dissonant) {
			e1 = target.Element1.Name.ToLower();
			e2 = target.Element2.Name.ToLower();
			msg += $"The target {target.ActorName}'s [color={e1}]{e1}[/color] reacted with it's [color={e2}]{e2}[/color] type to make [color={newType.Name.ToLower()}]{newType.Name.ToLower()}[/color].";

			(AttackEffect buff, AttackEffect debuff) = ElementManager.GetSideEffect(
					target.Element1, target.Element2);
			if(buff != null) {
				msg += $"\nThis reaction had side effects! " 
				+ $"{target.ActorName} received {buff.ApplyEffect(target)}";
			}
			if(debuff != null) {
				msg += $"\nThis reaction had side effects! " 
					+ $"{target.ActorName} received {debuff.ApplyEffect(target)}";
			}

			string msg2 = target.SetElement(0, newType);
			target.SetElement(1, ElementManager.Blank);
			if(msg2.Length > 0) {
				msg += $"\n{msg2}";
			}
			await gui.DisplayMessage(msg);
		}
	}
}
