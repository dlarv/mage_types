using Godot;
using System;

[GlobalClass]
public partial class ElementalEffect : StatusEffect {
	[Export]
	public ElementalType Element { get; set; }
}
