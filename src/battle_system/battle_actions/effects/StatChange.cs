using Godot;
using System;

[GlobalClass]
public partial class StatChange : StatusEffect {
	public int Stack { get; private set; } = 1;

    public override void Combine(StatusEffect a) {
		Duration = a.Duration;
		Stack += (int)(a.Strength / Math.Abs(a.Strength));
    }
}
