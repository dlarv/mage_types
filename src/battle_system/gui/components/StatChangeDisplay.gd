extends HBoxContainer 
class_name StatChangeDisplay 

@export
var mAttack : ColorRect 
@export
var rAttack : ColorRect 
@export
var mDefense : ColorRect 
@export
var rDefense : ColorRect 
@export
var speed : ColorRect 
@export
var evasion : ColorRect 

func Add(effect: StatChange) -> void:
	match effect.Name:
		StatusEffectManager.ATTACK_KEY:
			UpdateNibs(mAttack, effect.GetMod())
			UpdateNibs(rAttack, effect.GetMod())
			
		StatusEffectManager.DEFENSE_KEY:
			UpdateNibs(mDefense, effect.GetMod())
			UpdateNibs(rDefense, effect.GetMod())
			
		StatusEffectManager.MELEE_ATTACK_KEY:
			UpdateNibs(mAttack, effect.GetMod())
			
		StatusEffectManager.RANGED_ATTACK_KEY:
			UpdateNibs(rAttack, effect.GetMod())
			
		StatusEffectManager.MELEE_DEFENSE_KEY:
			UpdateNibs(mDefense, effect.GetMod())
			
		StatusEffectManager.RANGED_DEFENSE_KEY:
			UpdateNibs(rDefense, effect.GetMod())
		StatusEffectManager.SPEED_KEY:
			UpdateNibs(speed, effect.GetMod())
		_:
			UpdateNibs(evasion, effect.GetMod())

func UpdateNibs(rect: ColorRect, mod: float=1) -> void:
	var text = rect.tooltip_text
	# rect.TooltipText = Regex.Replace(rect.TooltipText, ":.*$", $": {mod:P0}")

	if mod == 1:
		rect.color = Color.GRAY
	elif mod < 1:
		rect.color = Color(mod - 1, 0, 0)
	else:
		rect.color = Color(0, mod - 1, 0)
func Remove(effect: StatChange) -> void:
	match effect.Name:
		StatusEffectManager.ATTACK_KEY:
			UpdateNibs(rAttack)
			UpdateNibs(mAttack)
			UpdateNibs(rAttack)
			
		StatusEffectManager.DEFENSE_KEY:
			UpdateNibs(mDefense)
			UpdateNibs(rDefense)
			
		StatusEffectManager.MELEE_ATTACK_KEY:
			UpdateNibs(mAttack)
			
		StatusEffectManager.RANGED_ATTACK_KEY:
			UpdateNibs(rAttack)
			
		StatusEffectManager.MELEE_DEFENSE_KEY:
			UpdateNibs(mDefense)
			
		StatusEffectManager.RANGED_DEFENSE_KEY:
			UpdateNibs(rDefense)
			
		StatusEffectManager.SPEED_KEY:
			UpdateNibs(speed)
		_:
			UpdateNibs(evasion)
