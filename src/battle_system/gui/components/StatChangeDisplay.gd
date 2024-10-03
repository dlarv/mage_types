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


func add(stat: StatManager.Stat, amount: float):
	match stat:
		StatManager.Stat.ATTACK:
			update_nibs(melee_attack, amount)
			update_nibs(ranged_attack, amount)
		StatManager.Stat.MELEE_ATTACK:
			update_nibs(melee_attack, amount)
		StatManager.Stat.RANGED_ATTACK:
			update_nibs(ranged_attack, amount)
		StatManager.Stat.DEFENSE:
			update_nibs(melee_defense, amount)
			update_nibs(ranged_defense, amount)
		StatManager.Stat.MELEE_DEFENSE:
			update_nibs(melee_defense, amount)
		StatManager.Stat.RANGED_DEFENSE:
			update_nibs(ranged_defense, amount)
		StatManager.Stat.SPEED: 
			update_nibs(speed, amount)
		StatManager.Stat.EVASION:
			update_nibs(evasion, amount)

func update_nibs(rect: ColorRect, mod: float=1) -> void:
	var text = rect.tooltip_text
	var index = text.rfind(":")
	# rect.TooltipText = Regex.Replace(rect.TooltipText, ":.*$", $": {mod:P0}")
	rect.tooltip_text = text.substr(0, index) + ": " + str(mod * 100) + "%"

	var colorChannel = mod / 5

	if mod == 1:
		rect.color = Color.GRAY
	elif mod < 1:
		# Approaching 0, red channel will be maxed.
		rect.color = Color(1 - mod, 0, 0)
	else:
		# At 500%, green channel will be maxed out.
		rect.color = Color(0, mod / 5, 0)

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
