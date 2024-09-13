using Godot;
using System;

public partial class EnemyActor : Node3D {
	[Export]
	public OpponentController Ai { get; set; }
	[Export]
	public BattleActor BattleActor { get; set; }
	public BattleActor[] Team { get => new BattleActor[] { BattleActor }; }

	public void OnBodyEntered(Node body) {
		GD.Print(body);
		if(!(body is StaticBody3D)) {
		}
	}
}
