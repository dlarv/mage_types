extends HBoxContainer 
class_name StatChangeDisplay 

@export
var melee_attack : ColorRect 
@export
var ranged_attack : ColorRect 
@export
var melee_defense : ColorRect 
@export
var ranged_defense : ColorRect 
@export
var speed : ColorRect 
@export
var evasion : ColorRect 


func add(effect: StatChange) -> void:
	match effect.name:
		StatusEffectManager.ATTACK_KEY:
			update_nibs(melee_attack, effect.get_mod())
			update_nibs(ranged_attack, effect.get_mod())
			
		StatusEffectManager.DEFENSE_KEY:
			update_nibs(melee_defense, effect.get_mod())
			update_nibs(ranged_defense, effect.get_mod())
			
		StatusEffectManager.MELEE_ATTACK_KEY:
			update_nibs(melee_attack, effect.get_mod())
			
		StatusEffectManager.RANGED_ATTACK_KEY:
			update_nibs(ranged_attack, effect.get_mod())
			
		StatusEffectManager.MELEE_DEFENSE_KEY:
			update_nibs(melee_defense, effect.get_mod())
			
		StatusEffectManager.RANGED_DEFENSE_KEY:
			update_nibs(ranged_defense, effect.get_mod())
		StatusEffectManager.SPEED_KEY:
			update_nibs(speed, effect.get_mod())
		_:
			update_nibs(evasion, effect.get_mod())

func update_nibs(rect: ColorRect, mod: float=1) -> void:
	var text = rect.tooltip_text
	var index = text.rfind(":")
	# rect.TooltipText = Regex.Replace(rect.TooltipText, ":.*$", $": {mod:P0}")
	rect.tooltip_text = text.substr(0, index) + ": " + str(mod * 100) + "%"

	if mod == 1:
		rect.color = Color.GRAY
	elif mod < 1:
		rect.color = Color(mod - 1, 0, 0)
	else:
		rect.color = Color(0, mod - 1, 0)
func remove(effect: StatChange) -> void:
	match effect.name:
		StatusEffectManager.ATTACK_KEY:
			update_nibs(melee_attack)
			update_nibs(ranged_attack)
			
		StatusEffectManager.DEFENSE_KEY:
			update_nibs(melee_defense)
			update_nibs(ranged_defense)
			
		StatusEffectManager.MELEE_ATTACK_KEY:
			update_nibs(melee_attack)
			
		StatusEffectManager.RANGED_ATTACK_KEY:
			update_nibs(ranged_attack)
			
		StatusEffectManager.MELEE_DEFENSE_KEY:
			update_nibs(melee_defense)
			
		StatusEffectManager.RANGED_DEFENSE_KEY:
			update_nibs(ranged_defense)
			
		StatusEffectManager.SPEED_KEY:
			update_nibs(speed)
		_:
			update_nibs(evasion)
