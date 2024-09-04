using Godot;
using System;

[GlobalClass]
public partial class Attack : BattleAction 
{
	public enum AttackRange { Melee, Ranged }

	[Export]
	public int Power;
	[Export]
	public AttackRange Range;


	public static Attack Create(string name, ElementalType element, int power, int range, string description="") 
	{
		Attack output = new Attack();
		output.Name = name;
		output.Element = element;
		output.Power = power;
		output.Range = (AttackRange)range;
		output.Details = description;
		return output;
	}
}
