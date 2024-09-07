using Godot;
using System;
using System.Collections.Generic;

public partial class StatusEffectManager : Node {
	// The Name field of all status effects should match one of these.
	const string MELEE_ATTACK_KEY = "Melee Attack";
	const string RANGED_ATTACK_KEY = "Ranged Attack";
	const string  MELEE_DEFENSE_KEY = "Melee Defense";
	const string RANGED_DEFENSE_KEY = "Ranged Defense";
	const string SPEED_KEY = "Speed";
	const string EVASION_KEY = "Evasion";
	const string STASIS_KEY = "Stasis";
	const string BLOCKING_KEY = "Blocking";
	const string POISON_KEY = "Poison";
	const string HEALING_KEY = "Healing";
	const string DISSONANT_KEY = "Dissonant";
	const string FLINCHING_KEY = "Flinching";
	const string PHOBIC_KEY = "Phobic";
	const string PHILIC_KEY = "Philic";

	public double MeleeAttackMod { get; set; } = 0;
	public double MeleeDefenseMod { get; set; } = 0;
	public double RangedAttackMod { get; set; } = 0;
	public double RangedDefenseMod { get; set; } = 0;
	public double SpeedMod { get; set; } = 0;
	public double EvasionMod { get; set; } = 0;

	public double Poison {
		get {
			StatusEffect poison;
			if(statuses.TryGetValue(POISON_KEY, out poison)) {
				if(GD.RandRange(0.0, 1.0) <= poison.Chance) {
					return poison.Strength;
				}
			}
			return 0;
		}
	}
	public double Healing {
		get {
			StatusEffect healing;
			if(statuses.TryGetValue(HEALING_KEY, out healing)) {
				if(GD.RandRange(0.0, 1.0) <= healing.Chance) {
					return healing.Strength;
				}
			}
			return 0;
		}
	}

	private bool isBlocking = false;
	private bool inStasis = false;

	private Dictionary<string, StatusEffect> statuses = new();

	public void Add(StatusEffect status) {
		switch(status.Name) {
			case MELEE_ATTACK_KEY:
				MeleeAttackMod += status.Strength;
				break;
			case MELEE_DEFENSE_KEY:
				MeleeDefenseMod += status.Strength;
				break;
			case RANGED_ATTACK_KEY:
				RangedAttackMod += status.Strength;
				break;
			case RANGED_DEFENSE_KEY:
				RangedAttackMod += status.Strength;
				break;
			case SPEED_KEY:
				SpeedMod += status.Strength;
				break;
			case EVASION_KEY:
				EvasionMod += status.Strength;
				break;
			case BLOCKING_KEY:
				isBlocking = true;
				break;
			case STASIS_KEY:
				inStasis = true;
				break;
			default:
				if(statuses.ContainsKey(status.Name)) {
					statuses[status.Name] += status;
				} else {
					statuses.Add(status.Name, status);
				}
				break;
		}
	}

	public void CalculateExpirations() {
		List<StatusEffect> effects = new();
		foreach(StatusEffect effect in statuses.Values) {
			effect.Duration--;
			if(effect.IsExpired()) {
				effects.Add(effect);
			}
		}
		foreach(StatusEffect effect in effects) {
			statuses.Remove(effect.Name);
		}
	}
	/* Status Effect Methods */
	public bool IsFlinching() {
		return statuses.ContainsKey(FLINCHING_KEY);
	}
	public bool IsDissonant() {
		return statuses.ContainsKey(DISSONANT_KEY);
	}
	public bool IsBlocking() {
		if(isBlocking) {
			isBlocking = false;
			return true;
		}
		return false;
	}
	public bool InStasis() {
		if(inStasis) {
			inStasis = false;
			return true;
		}
		return false;
	}
	public bool IsPhobic(ElementalType element, out StatusEffect mod) {
		StatusEffect effect;
		if(statuses.TryGetValue(PHOBIC_KEY, out effect)) {
			mod = effect;
			return ((ElementalEffect)effect).Element.Name == element.Name;
		}
		mod = null;
		return false;
	}
	public bool IsPhilic(ElementalType element, out StatusEffect mod) {
		StatusEffect effect;
		if(statuses.TryGetValue(PHILIC_KEY, out effect)) {
			mod = effect;
			return ((ElementalEffect)effect).Element.Name == element.Name;
		}
		mod = null;
		return false;
	}
	public StatusEffect[] List() {
		StatusEffect[] output = new StatusEffect[statuses.Count];
		int i = 0;
		foreach(StatusEffect effect in statuses.Values) {
			output[i++] = effect;
		}
		return output;
	}
}
