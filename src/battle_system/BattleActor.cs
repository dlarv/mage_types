using Godot;
using Godot.Collections;
using System;

[GlobalClass]
public partial class BattleActor : Node {
	public const int MAX_STAT = 1000;

	[Export]
	public string ActorName; 

	[ExportCategory("Stats")]
	private int _hp;
	[Export]
	public int Hp { 
		get => _hp; 
		set {
			_hp = value;
			CurrentHp = value;
		}
	}
	public int CurrentHp { get; set; }
	[Export]
	public int MeleeAttack { get; set; }
	[Export]
	public int RangedAttack { get; set; }
	[Export]
	public int MeleeDefense { get; set; }
	[Export]
	public int RangedDefense { get; set; }
	[Export]
	public int Speed { get; set; }
	[Export]
	public int Evasion { get; set; }

	[ExportCategory("General")]
	[Export]
	public ElementalType Element1 { get; private set; }
	[Export]
	public ElementalType Element2 { get; private set; }
	[Export]
	public Attack[] Attacks { get; set; }
	[Export]
	public Sprite Sprite = null;
	/*public Sprite2D Sprite = null;*/
	/*protected bool use_gradient_sprite = false;*/

    public override void _Ready() {
        base._Ready();

		Sprite = new();
		Sprite.SetGradientSprite(Element1, Element2);
		if(Sprite == null) {
			Sprite = new();
			Sprite.SetGradientSprite(Element1, Element2);
		} 

		var elementManager = GetNode<ElementManager>("/root/ElementManager");
		// If only one element is blank, it should be the second one.
		if(Element1 == null && Element2 != null) {
			Element1 = Element2;
			Element2 = elementManager.GetElementFromName("blank");
		}
		// The Blank Element should be used for empty types instead of null.
		if(Element1 == null) {
			Element1 = elementManager.GetElementFromName("blank");
		}
		if(Element2 == null) {
			Element2 = elementManager.GetElementFromName("blank");
		}
	}
    

	public void SetElement(int id, ElementalType element) {
		if(id == 0) {
			Element1 = element;
		} else {
			Element2 = element;
		}
		Sprite.SetElement(id, element);
	}
	
	public static BattleActor Create(string actorName, ElementalType element1, ElementalType element2, Attack[] attacks, Dictionary<string, int> stats) {
		BattleActor actor = new BattleActor();
		actor.ActorName = actorName;
		actor.Element1 = element1;
		actor.Element2 = element2;
		actor.Attacks = attacks;

		foreach(var stat in stats) {
			switch(stat.Key) {
				case "hp":
					actor.Hp = stat.Value;
					actor.CurrentHp = actor.Hp;
					break;
				case "attack":
					actor.MeleeAttack = stat.Value;
					actor.RangedAttack = stat.Value;
					break;
				case "defense":
					actor.MeleeDefense = stat.Value;
					actor.RangedDefense = stat.Value;
					break;
				case "melee_attack":
					actor.MeleeAttack = stat.Value;
					break;
				case "ranged_attack":
					actor.RangedAttack = stat.Value;
					break;
				case "melee_defense":
					actor.MeleeDefense = stat.Value;
					break;
				case "ranged_defense":
					actor.RangedDefense = stat.Value;
					break;
				case "speed":
					actor.Speed = stat.Value;
					break;
			}
		}

		actor.Sprite = new Sprite();
		actor.Sprite.SetGradientSprite(actor.Element1, actor.Element2);
		return actor;
	}

	public void UseGradientSprite() {
		Sprite = new Sprite();
		Sprite.SetGradientSprite(Element1, Element2);
	}

	public static int GetMaxStat() {
		return MAX_STAT;
	}
	public Dictionary<string, int> GetStats() {
		return new Dictionary<string, int>() {
			{ "hp", Hp },
			{ "attack", MeleeAttack },
			{ "defense", MeleeDefense },
			{ "speed", MeleeDefense },
		};
	}
	public int GetStat(string name) {
		switch(name.ToLower().Trim()) {
			case "hp": return Hp;
			case "attack": case "melee_attack": return MeleeAttack;
			case "defense": case "melee_defense": return MeleeDefense;
			case "ranged_attack": return RangedAttack;
			case "ranged_defense": return RangedDefense;
			case "speed": return Speed;
			default: return -1;
		}
	}
	public void SetStat(string name, int value) {
		switch(name.ToLower().Trim()) {
			case "hp": 
				Hp = value;
				CurrentHp = value;
				break;
			case "attack": case "melee_attack": 
				MeleeAttack = value;
				break;
			case "defense": case "melee_defense": 
				MeleeDefense = value;
				break;
			case "ranged_attack": 
				RangedAttack = value;
				break;
			case "ranged_defense": 
				RangedDefense = value;
				break;
			case "speed": 
				Speed = value;
				break;
		}
	}
	public int GetAttackStat(BattleAction action) {
		if(action.Range == BattleAction.AttackRange.Melee) {
			return MeleeAttack;
		}
		return RangedAttack;
	}
	public int GetDefenseStat(BattleAction action) {
		if(action.Range == BattleAction.AttackRange.Melee) {
			return MeleeDefense;
		}
		return RangedDefense;
	}
}
