extends HBoxContainer 
class_name StatChangeDisplay 

@export var melee_attack: TextureRect
@export var ranged_attack: TextureRect 
@export var melee_defense: TextureRect 
@export var ranged_defense: TextureRect 
@export var speed: TextureRect 

func add(stat: StatManager.Stat, amount: float) -> void:
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

func update_nibs(rect: TextureRect, mod: float=1) -> void:
	var text = rect.tooltip_text
	var index = text.rfind(":")
	rect.tooltip_text = text.substr(0, index) + ": " + str(mod * 100) + "%"

	if mod == 1:
		rect.modulate = Color.GRAY
	elif mod < 1:
		# Approaching 0, red channel will be maxed.
		rect.modulate = Color(1 - mod, 0, 0)
	else:
		# At 500%, green channel will be maxed out.
		rect.modulate = Color(0, mod / StatManager.MAX_MOD, 0)

