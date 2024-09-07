using Godot;
using System;

[GlobalClass]
public partial class AttackEffect : Resource {
	[Export]
	public StatusEffect Effect { get; private set; }
	[Export(PropertyHint.Range, "0, 1")]
	public double Chance { get; private set; }
}
