using Godot;
using System;
using System.Collections.Generic;

public partial class StatusEffectManager : Node {
	// The Name field of all status effects should match one of these.
	public const string ATTACK_KEY = "Attack";
	public const string DEFENSE_KEY = "Defense";
	public const string MELEE_ATTACK_KEY = "Melee Attack";
	public const string RANGED_ATTACK_KEY = "Ranged Attack";
	public const string MELEE_DEFENSE_KEY = "Melee Defense";
	public const string RANGED_DEFENSE_KEY = "Ranged Defense";
	public const string SPEED_KEY = "Speed";
	public const string EVASION_KEY = "Evasion";
	public const string STASIS_KEY = "Stasis";
	public const string BLOCKING_KEY = "Blocking";
	public const string POISON_KEY = "Poison";
	public const string HEALING_KEY = "Healing";
	public const string DISSONANT_KEY = "Dissonant";
	public const string FLINCHING_KEY = "Flinching";
	public const string PHOBIC_KEY = "Phobic";
	public const string PHILIC_KEY = "Philic";

	public double MeleeAttackMod { 
		get {
			double total = 1;
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				total += ((StatChange)effect).GetMod();
			}
			if(statuses.TryGetValue(ATTACK_KEY, out effect)) {
				total += ((StatChange)effect).GetMod();
			}
			return total;
		}
	}
	public double MeleeDefenseMod { 
		get {
			double total = 1;
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_DEFENSE_KEY, out effect)) {
				total += ((StatChange)effect).GetMod();
			}
			if(statuses.TryGetValue(DEFENSE_KEY, out effect)) {
				total += ((StatChange)effect).GetMod();
			}
			return total;
		}
	}
	public double RangedAttackMod {
		get {
			double total = 1;
			StatusEffect effect;
			if(statuses.TryGetValue(RANGED_ATTACK_KEY, out effect)) {
				total += ((StatChange)effect).GetMod();
			}
			if(statuses.TryGetValue(ATTACK_KEY, out effect)) {
				total += ((StatChange)effect).GetMod();
			}
			return total;
		}
	}
	public double RangedDefenseMod {
		get {
			double total = 1;
			StatusEffect effect;
			if(statuses.TryGetValue(RANGED_DEFENSE_KEY, out effect)) {
				total += ((StatChange)effect).GetMod();
			}
			if(statuses.TryGetValue(DEFENSE_KEY, out effect)) {
				total += ((StatChange)effect).GetMod();
			}
			return total;
		}
	}
	public double SpeedMod {
		get {
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				return ((StatChange)effect).GetMod();
			}
			return 1;
		}
	}
	public double EvasionMod {
		get {
			StatusEffect effect;
			if(statuses.TryGetValue(MELEE_ATTACK_KEY, out effect)) {
				return ((StatChange)effect).GetMod();
			}
			return 1;
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
	private List<StatusEffect> effectsToRemove = new();

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
	public StatusEffect Get(StatusEffect status) {
		switch(status.Name) {
			case BLOCKING_KEY:
				return blocking;
			case STASIS_KEY:
				return stasis;
			default:
				return statuses.GetValueOrDefault(status.Name, null);
		}
	}
	public void Remove(StatusEffect[] effects) {
		foreach(StatusEffect effect in effects) {
			statuses.Remove(effect.Name);
		}
	}
	public void Remove(StatusEffect effect) {
		statuses.Remove(effect.Name);
	}

	public StatusEffect[] CalculateExpirations() {
		foreach(StatusEffect effect in statuses.Values) {
			effect.Duration--;
			if(effect.IsExpired()) {
				effectsToRemove.Add(effect);
			}
		}
		foreach(StatusEffect effect in effectsToRemove) {
			statuses.Remove(effect.Name);
		}
		var output = effectsToRemove.ToArray();
		effectsToRemove = new();
		return output;
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
			effectsToRemove.Add(blocking);
			blocking = null;
			return true;
		}
		return false;
	}
	public bool InStasis() {
		if(stasis != null) {
			effectsToRemove.Add(stasis);
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
