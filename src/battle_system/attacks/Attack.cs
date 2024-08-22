using Godot;
using System;

public partial class Attack : Node
{
	public enum Range { Melee, Ranged, Self }

	[Export]
	public int power;
	[Export]
	public Range range;
	[Export]
	public Element element;
}
