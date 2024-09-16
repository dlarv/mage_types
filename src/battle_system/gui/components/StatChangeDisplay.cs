using Godot;
using System;
using System.Text.RegularExpressions;

public partial class StatChangeDisplay : HBoxContainer {
	[Export]
	private ColorRect mAttack { get; set; }
	[Export]
	private ColorRect rAttack { get; set; }
	[Export]
	private ColorRect mDefense { get; set; }
	[Export]
	private ColorRect rDefense { get; set; }
	[Export]
	private ColorRect speed { get; set; }
	[Export]
	private ColorRect evasion { get; set; }

	public void Add(StatChange effect) {
		switch(effect.Name) {
			case StatusEffectManager.ATTACK_KEY:
				UpdateNibs(mAttack, effect.GetMod());
				UpdateNibs(rAttack, effect.GetMod());
				break;
			case StatusEffectManager.DEFENSE_KEY:
				UpdateNibs(mDefense, effect.GetMod());
				UpdateNibs(rDefense, effect.GetMod());
				break;
			case StatusEffectManager.MELEE_ATTACK_KEY:
				UpdateNibs(mAttack, effect.GetMod());
				break;
			case StatusEffectManager.RANGED_ATTACK_KEY:
				UpdateNibs(rAttack, effect.GetMod());
				break;
			case StatusEffectManager.MELEE_DEFENSE_KEY:
				UpdateNibs(mDefense, effect.GetMod());
				break;
			case StatusEffectManager.RANGED_DEFENSE_KEY:
				UpdateNibs(rDefense, effect.GetMod());
				break;
			case StatusEffectManager.SPEED_KEY:
				UpdateNibs(speed, effect.GetMod());
				break;
			case StatusEffectManager.EVASION_KEY:
			default:
				UpdateNibs(evasion, effect.GetMod());
				break;
		}
	}
	private void UpdateNibs(ColorRect rect, double mod=1) {
		string text = rect.TooltipText;
		rect.TooltipText = Regex.Replace(rect.TooltipText, ":.*$", $": {mod:P0}");

		if(mod == 1) {
			rect.Color = Colors.Gray;
		}
		else if(mod < 1) {
			rect.Color = new Color(1 * (float)mod - 1, 0, 0);
		} else {
			rect.Color = new Color(0, (float)mod - 1, 0);
		}
	}
	public void Remove(StatChange effect) {
		switch(effect.Name) {
			case StatusEffectManager.ATTACK_KEY:
				UpdateNibs(rAttack);
				UpdateNibs(mAttack);
				UpdateNibs(rAttack);
				break;
			case StatusEffectManager.DEFENSE_KEY:
				UpdateNibs(mDefense);
				UpdateNibs(rDefense);
				break;
			case StatusEffectManager.MELEE_ATTACK_KEY:
				UpdateNibs(mAttack);
				break;
			case StatusEffectManager.RANGED_ATTACK_KEY:
				break;
			case StatusEffectManager.MELEE_DEFENSE_KEY:
				UpdateNibs(mDefense);
				break;
			case StatusEffectManager.RANGED_DEFENSE_KEY:
				UpdateNibs(rDefense);
				break;
			case StatusEffectManager.SPEED_KEY:
				UpdateNibs(speed);
				break;
			case StatusEffectManager.EVASION_KEY:
			default:
				UpdateNibs(evasion);
				break;
		}
	}
}
