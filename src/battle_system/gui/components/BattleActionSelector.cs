using Godot;
using System;

public partial class BattleActionSelector : Control
{
	[Export]
	private Control attackButtonParent;

	public BattleActionSelector(BattleActor actor) {
		foreach(BattleAction attack in actor.Attacks) {
		}
	}
}
