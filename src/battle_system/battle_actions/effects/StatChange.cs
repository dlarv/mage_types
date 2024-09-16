using Godot;
using System;

[Tool]
[GlobalClass]
public partial class StatChange : StatusEffect {
	// How each stack increases.
	public const double STACK_MODIFIER = 0.3;
	public double Stack { get; private set; } = STACK_MODIFIER;

    public override void Combine(StatusEffect a) {
		Duration = a.Duration;
		Stack += STACK_MODIFIER * (a.Strength / Math.Abs(a.Strength));
    }

	public double GetMod() {
		return Stack * Strength + 1;
	}
}
