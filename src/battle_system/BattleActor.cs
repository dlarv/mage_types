using Godot;
using System;

public partial class BattleActor : Node
{
	[Export]
	public string actor_name;
	[Export]
	public int hp;
	[Export]
	public int current_hp;
	[Export]
	public int melee_attack;
	[Export]
	public int ranged_attack;
	[Export]
	public int melee_defense;
	[Export]
	public int ranged_defense;
	[Export]
	public int speed;
	[Export]
	public int evasion;

	[Export]
	public Element element1;
	[Export]
	public Element element2;
	[Export]
	public Attack[] attacks;
	[Export]
	public Sprite2D sprite;
}
