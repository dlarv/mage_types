using Godot;
using System;
using System.Linq;

public partial class Battle : Node
{
	private BattleActor[] enemies;
	private BattleActor[] allies;
	private BattleActor[] actors;
	private BattleGUI gui;
	private OpponentController ai;

	public void StartBattle(BattleActor[] allies, BattleActor[] enemies, OpponentController ai) 
	{
		this.allies = allies;
		this.enemies = enemies;
		this.actors = allies.Concat(enemies).ToArray();
		this.ai = ai;

		gui = new BattleGUI(allies, enemies);
		AddChild(gui);
	}

	public void OnPlayerActionsSelected(BattleAction[] actions) {
	}
}
