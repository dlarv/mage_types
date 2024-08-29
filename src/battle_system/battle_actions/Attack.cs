using Godot;
using System;

[GlobalClass]
public partial class Attack : BattleAction 
{
	public enum AttackRange { Melee, Ranged, Self }

	[Export]
	public int Power;
	[Export]
	public AttackRange Range;


	public static Attack Create(string name, Element element, int power, int range) 
	{
		Attack output = new Attack();
		output.Name = name;
		output.Element = element;
		output.Power = power;
		output.Range = (AttackRange)range;
		return output;
	}
}
