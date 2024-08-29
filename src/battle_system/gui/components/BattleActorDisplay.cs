using Godot;
using System;
/*
 * Shows information about a battle actor.
 * Name, Sprite, Health
 */

public partial class BattleActorDisplay : Control
{
	[Export]
	private Label nameLabel;
	[Export]
	private HSlider healthBar;
	[Export]
	private Label hpLabel;
	[Export]
	private TextureRect sprite;

	public BattleActorDisplay(BattleActor actor) {
		nameLabel.Text = actor.ActorName;
		healthBar.Value = (actor.CurrentHp / actor.Hp) * 100;
		hpLabel.Text = $"{actor.CurrentHp}/{actor.Hp}";
	}
}
