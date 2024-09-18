using Godot;
using System;

[Tool]
[GlobalClass]
public partial class BaseCompanion : CharacterBody3D {
	[Export]
	public Node3D PlayerTarget { get; set; }
	[Export]
	public BattleActor BattleActor { get; set; }
	[Export]
	public float Speed { get; set; }
	[Export]
	public float DistanceToPlayer { get; set; }
	[Export]
	public float MaxDistance { get; set; } = 10;

	public override void _PhysicsProcess(double delta) {
		// See if companion is within target distance.
		Vector3 playerPos = PlayerTarget.GlobalPosition; 
		float distance = playerPos.DistanceTo(GlobalPosition);
		if((distance < MaxDistance && Velocity == Vector3.Zero) || distance <= DistanceToPlayer) {
			Velocity = Vector3.Zero;
			return;
		} 

		Vector3 velocity = GlobalPosition.DirectionTo(playerPos);
		velocity.Y = 0;
		velocity *= new Vector3(Speed, 0, Speed);
		Velocity = velocity;

		MoveAndSlide();
	}
}
