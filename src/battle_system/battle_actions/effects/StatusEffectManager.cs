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

	public double MeleeAttackMod { 
		get {
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				return effect.Strength * ((StatChange)effect).Stack;
			}
			return 0;
		}
	}
	public double MeleeDefenseMod { 
		get {
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				return effect.Strength * ((StatChange)effect).Stack;
			}
			return 0;
		}
	}
	public double RangedAttackMod {
		get {
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				return effect.Strength * ((StatChange)effect).Stack;
			}
			return 0;
		}
	}
	public double RangedDefenseMod {
		get {
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				return effect.Strength * ((StatChange)effect).Stack;
			}
			return 0;
		}
	}
	public double SpeedMod {
		get {
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				return effect.Strength * ((StatChange)effect).Stack;
			}
			return 0;
		}
	}
	public double EvasionMod {
		get {
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				return effect.Strength * ((StatChange)effect).Stack;
			}
			return 0;
		}
	}

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

	private StatusEffect blocking = null;
	private StatusEffect stasis = null;

	private Dictionary<string, StatusEffect> statuses = new();

	public void Add(StatusEffect status) {
		switch(status.Name) {
			case BLOCKING_KEY:
				blocking = status;
				break;
			case STASIS_KEY:
				stasis = status;
				break;
			default:
				if(statuses.ContainsKey(status.Name)) {
					statuses[status.Name].Combine(status);
				} else {
					statuses.Add(status.Name, status);
				}
				break;
		}
	}

	public StatusEffect[] CalculateExpirations() {
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
		return effects.ToArray();
	}
	/* Status Effect Methods */
	public bool IsFlinching() {
		return statuses.ContainsKey(FLINCHING_KEY);
	}
	public bool IsDissonant() {
		return statuses.ContainsKey(DISSONANT_KEY);
	}
	public bool IsBlocking() {
		if(blocking != null) {
			blocking = null;
			return true;
		}
		return false;
	}
	public bool InStasis() {
		if(stasis != null) {
			stasis = null;
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
		List<StatusEffect> output = new();
		if(blocking != null) {
			output.Add(blocking);
		}
		if(stasis != null) {
			output.Add(stasis);
		}

		foreach(StatusEffect effect in statuses.Values) {
			output.Add(effect);
		}
		return output.ToArray();
	}
}
