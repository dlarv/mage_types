using Godot;
using Godot.Collections;
using System;

[GlobalClass]
public partial class BattleActor : Node {
	public const int MAX_STAT = 1000;

	[Signal]
	public delegate void WasDefeatedEventHandler();
	[Signal]
	public delegate void StatusEffectAddedEventHandler(StatusEffect effect);
	[Signal]
	public delegate void StatusEffectsRemovedEventHandler(StatusEffect[] effect);
	[Signal]
	public delegate void DamageAppliedEventHandler(int hp);
	[Signal]
	public delegate void ElementChangedEventHandler(int id, ElementalType element);

	[Export]
	public string ActorName = "Guy"; 

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
	public int MeleeAttack { 
		get { return (int)(_meleeAttack + statuses.MeleeAttackMod); }
		set => _meleeAttack = value; 
	}
	private int _meleeAttack;
	[Export]
	public int RangedAttack { 
		get { return (int)(_rangedAttack + statuses.RangedAttackMod); }
		set => _rangedAttack = value; 
	}
	private int _rangedAttack;
	[Export]
	public int MeleeDefense { 
		get { return (int)(_meleeDefense + statuses.MeleeDefenseMod); }
		set => _meleeDefense = value; 
	}
	public int _meleeDefense;
	[Export]
	public int RangedDefense { 
		get { return (int)(_rangedDefense+ statuses.RangedDefenseMod); }
		set => _rangedDefense = value; 
	}
	private int _rangedDefense;
	[Export]
	public int Speed { 
		get { return (int)(_speed + statuses.SpeedMod); }
		set => _speed = value; 
	}
	private int _speed;
	[Export]
	public int Evasion { 
		get { return (int)(_evasion + statuses.EvasionMod); }
		set => _evasion = value; 
	}
	private int _evasion;

	[ExportCategory("General")]
	[Export]
	public ElementalType Element1 { get; private set; } = ElementManager.Blank;
	[Export]
	public ElementalType Element2 { get; private set; } = ElementManager.Blank;
	[Export]
	public ElementalType ElementalBias { get; private set; } = ElementManager.Blank;
	[Export]
	public Attack[] Attacks { get; set; }
	[Export]
	public Sprite Sprite = null;

	private StatusEffectManager statuses = new();
	public bool Dissonant { get => statuses.IsDissonant(); }
	public bool Flinching { get => statuses.IsFlinching(); }
	public bool InStasis { get => statuses.InStasis(); }
	public bool Defeated { get => CurrentHp <= 0; }

	private bool aleadyDefeated = false;

    public override void _Ready() {
        base._Ready();

		Sprite = new();
		Sprite.SetGradientSprite(Element1, Element2);
		/*if(Sprite == null) {*/
		/*	Sprite = new();*/
		/*	Sprite.SetGradientSprite(Element1, Element2);*/
		/*} */

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

	public string SetElement(int id, ElementalType element) {
		string msg = "";
		if(id == 0) {
			Element1 = element;
		} else {
			Element2 = element;
		}
		Sprite.SetElement(id, element);
		EmitSignal(SignalName.ElementChanged, id, element);

		StatusEffect mod;
		int dmg;
		if(statuses.IsPhobic(element, out mod)) {
			dmg = (int)((double)Hp * mod.Strength);
			CurrentHp -= dmg;
			msg += $"{ActorName} was hurt by its phobia! ({dmg} damage)";
		}
		else if(statuses.IsPhilic(element, out mod)) {
			dmg = (int)((double)Hp * mod.Strength);
			CurrentHp += dmg;
			msg += $"{ActorName} was healed by its philia! ({dmg} damage)";
		}
		return msg;
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
	// Returns actual amount of damage applied, after accounting for status conditions.
	public int ApplyDamage(int dmg) {
		if(!statuses.IsBlocking()) {
			CurrentHp -= dmg;
			EmitSignal(SignalName.DamageApplied, CurrentHp);
			if(CurrentHp <= 0 && !aleadyDefeated) {
				aleadyDefeated = true;
				EmitSignal(SignalName.WasDefeated);
			}
			return dmg;
		}
		return 0;
	}
	public void AddStatusEffect(StatusEffect effect) {
		statuses.Add(effect);
		EmitSignal(SignalName.StatusEffectAdded, effect);
	}

	/* Status Effect Methods */
	public bool TryRevertToBias() {
		return false;
	}
	public StatusEffect[] ListStatusEffects() {
		return statuses.List();
	}
	public string ResolveEndOfTurn() {
		// Calc poison and healing.
		string msg = "";
		double mod = 0;
		double poison = statuses.Poison;
		double healing = statuses.Healing;

		if(poison > 0) {
			mod += poison;
			msg += $"{ActorName} was hurt by poison ({Hp * poison})";
		}
		if(healing > 0) {
			mod -= healing;
			msg += $"{ActorName} recovered {Hp * healing} health";
		}
		CurrentHp -= (int)((double)Hp * mod);
		EmitSignal(SignalName.DamageApplied, CurrentHp);

		StatusEffect[] effects = statuses.CalculateExpirations();
		EmitSignal(SignalName.StatusEffectsRemoved, effects);
		return msg;
	}
}
