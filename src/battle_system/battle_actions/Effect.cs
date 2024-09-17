using Godot;
using System;

[Tool]
[GlobalClass]
public partial class Effect : Resource {
	[Export]
	public AttackEffect AttackEffect { get; private set; }
	[Export(PropertyHint.Range, "0, 1")]
	public double Chance { get; private set; } = 1;
}
