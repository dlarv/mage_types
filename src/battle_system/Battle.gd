extends Node
class_name Battle 

signal BattleEnded();

# BattleActor[]
var enemies = []
var allies = []
var actors = []

@export
var gui: BattleGUI
@export
var ai: OpponentController 
@export
var matchupManager: CanvasLayer

var defeatedAllies : int = 0;
var defeatedEnemies : int = 0;

func _unhandled_input(event) -> void:
	if event.is_action_pressed("open_pause_menu"):
		matchupManager.visible = !matchupManager.visible;

func Start(allies, allyItems, enemies, ai) -> void:
	self.allies = allies;
	self.enemies = enemies;
	actors = allies
	actors.append_array(enemies)

	for ally in allies:
		ally.WasDefeated.connect(func(): defeatedAllies += 1)
	for enemy in enemies:
		enemy.WasDefeated.connect(func(): defeatedEnemies += 1)

	gui.Setup(allies, allyItems, enemies);

func OnPlayerActionsSelected(allyActions) -> void:
	# If allyActions is empty, the player pressed the "Run" button.
	if len(allyActions) == 0:
		await gui.DisplayMessage("You ran away.");
		BattleEnded.emit()

	gui.EnablePlayerControls(false);
	var enemyActions = ai.GetActions(enemies, allies);
	var actions = allyActions
	actions.append_array(enemyActions)

	# Calculate turn order based on priority and actor speed.
	actions.sort();

	for action in actions:
		# This means a character is defeated or flinched.
		if action == null:
			continue;

		if action.actor.Flinching:
			continue;

		action.action.ApplyCost(action.actor);

		# Play animation.
		var userPosition = gui.GetActorDisplayPosition(action.teamIndex, action.actor);
		var targetTeamIndex;
		var teamDisplay;
		# Target same team as user.
		if(action.action.Target == BattleAction.TargetType.Self \
				or action.action.Target == BattleAction.TargetType.Ally \
				or action.action.Target == BattleAction.TargetType.Allies):
			targetTeamIndex = action.teamIndex;
			teamDisplay =  gui.AllyDisplayParent  if action.teamIndex == 0  else  gui.EnemyDisplayParent
		# Target opposite team from user.
		else:
			targetTeamIndex = (action.teamIndex + 1) % 2;
			teamDisplay =  gui.AllyDisplayParent  if action.teamIndex == 1  else  gui.EnemyDisplayParent
		var targetPosition = gui.GetActorDisplayPosition( targetTeamIndex, action.targets[0] if len(action.targets) == 1 else null);
		
		var animation = action.action.PlayAnimation(userPosition, targetPosition);
		add_child(animation);

		# Apply action effects.
		var msg = action.action.ApplyEffects(action.actor, action.targets);

		# Display message and await input.
		await gui.DisplayMessage(msg);

		# Calculate target transmutations.
		for target in action.targets:
			await CalculateTransmutations(target, action.action);

		# Calculate user transmutations.
		# If the user targeted themselves 
		# (e.g. Target = Allies || Self || Ally).
		# This only applies to melee attacks.
		if(action.targets.find(action.actor) == -1 \
				and action.action is Attack \
				and (action.action).attack_range == Attack.AttackRange.Melee):
			await CalculateTransmutations(action.actor, action.action); 

		# Resolve user's status effects.
		msg = action.actor.ResolveEndOfTurn();		
		if len(msg) > 0:
			await gui.DisplayMessage(msg);

		# Check if battle should end.
		if defeatedAllies == len(allies):
			await gui.DisplayMessage("You were defeated...");
			BattleEnded.emit()
		elif defeatedEnemies == len(enemies):
			await gui.DisplayMessage("You won!");
			BattleEnded.emit()
		# Pause before processing next turn.
		await get_tree().create_timer(0.5).timeout
	gui.EnablePlayerControls(true);

func CalculateTransmutations(target: BattleActor, action: BattleAction) -> void:
	return
# 	var msg = "";
# 	var e1 = target.Element1.Name.ToLower();
# 	var e2 = target.Element2.Name.ToLower();
# 	var ea = action.Element.Name.ToLower();
#
# 	# Calculate primary + attack 
# 	ElementalType newType = ElementManager.GetMatchup(target.Element1, action.Element);
# 	if newType != null:
# 		msg += $"The target {target.ActorName}'s [color={e1}]{e1}[/color] reacted with the attack's [color={ea}]{ea}[/color] type to make [color={newType.Name.ToLower()}]{newType.Name.ToLower()}[/color].\n";
# 		(AttackEffect buff, AttackEffect debuff) = ElementManager.GetSideEffect(
# 				target.Element1, action.Element);
# 		if buff != null:
# 			msg += $"\nThis reaction had side effects! "
# 			+ $"{target.ActorName} received {buff.ApplyEffect(target)}";
# 		}
# 		if debuff != null:
# 			msg += $"\nThis reaction had side effects! "
# 			+ $"{target.ActorName} received {debuff.ApplyEffect(target)}";
# 		}
#
# 		string msg2 = target.SetElement(0, newType);
# 		if len(msg2) > 0:
# 			msg += $"\n{msg2}";
# 		}
# 	}
#
# 	# Calculate secondary + attack 
# 	newType = ElementManager.GetMatchup(target.Element2, action.Element);
# 	if newType != null && !target.InStasis:
# 		msg += $"\nThe target {target.ActorName}'s [color={e2}]{e2}[/color] reacted with the attack's [color={ea}]{ea}[/color] type to make [color={newType.Name.ToLower()}]{newType.Name.ToLower()}[/color].";
#
# 		(AttackEffect buff, AttackEffect debuff) = ElementManager.GetSideEffect(
# 				target.Element2, action.Element);
# 		if buff != null:
# 			msg += $"\nThis reaction had side effects! " 
# 			+ $"{target.ActorName} received {buff.ApplyEffect(target)}";
# 		}
# 		if debuff != null:
# 			msg += $"\nThis reaction had side effects! " 
# 				+ $"{target.ActorName} received {debuff.ApplyEffect(target)}";
# 		}
# 		string msg2 = target.SetElement(1, newType);
# 		if len(msg2) > 0:
# 			msg += $"\n{msg2}";
# 		}
# 	}
#
# 	# Only display message if applicable.
# 	# If no changes occurred, iteration can end here.
# 	if len(msg) > 0:
# 		await gui.DisplayMessage(msg);
# 	} else return;
#
# 	# Calculate primary + secondary.
# 	newType = ElementManager.GetMatchup(target.Element1, target.Element2);
# 	if newType != null && !target.Dissonant:
# 		e1 = target.Element1.Name.ToLower();
# 		e2 = target.Element2.Name.ToLower();
# 		msg = $"The target {target.ActorName}'s [color={e1}]{e1}[/color] reacted with it's [color={e2}]{e2}[/color] type to make [color={newType.Name.ToLower()}]{newType.Name.ToLower()}[/color].";
#
# 		(AttackEffect buff, AttackEffect debuff) = ElementManager.GetSideEffect(
# 				target.Element1, target.Element2);
# 		if buff != null:
# 			msg += $"\nThis reaction had side effects! " 
# 			+ $"{target.ActorName} received {buff.ApplyEffect(target)}";
# 		}
# 		if debuff != null:
# 			msg += $"\nThis reaction had side effects! " 
# 				+ $"{target.ActorName} received {debuff.ApplyEffect(target)}";
# 		}
#
# 		string msg2 = target.SetElement(0, newType);
# 		target.SetElement(1, ElementManager.Blank);
# 		if len(msg2) > 0:
# 			msg += $"\n{msg2}";
# 		}
# 		await gui.DisplayMessage(msg);
# 	}
# }
