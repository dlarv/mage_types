using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

[GlobalClass]
public partial class Battle : Node
{
	private BattleActor[] enemies;
	private BattleActor[] allies;
	private BattleActor[] actors;
	[Export]
	private BattleGUI gui;
	private OpponentController ai;

	public void Start(BattleActor[] allies, BattleItem[] allyItems, BattleActor[] enemies, OpponentController ai) 
	{
		this.allies = allies;
		this.enemies = enemies;
		this.actors = allies.Concat(enemies).ToArray();
		this.ai = ai;

		gui.Setup(allies, allyItems, enemies);
	}

	public void OnPlayerActionsSelected(ActorAction[] allyActions) {
		ActorAction[] enemyActions = ai.GetActions(enemies, allies);
		List<ActorAction> actions = new(allyActions.Length + enemyActions.Length);

		// Calculate priority.
		actions.Sort();

		// 
	}

}

