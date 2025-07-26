extends Node
class_name StatChangeDisplay 

const StatDisplay := preload("res://src/battle_system/gui/components/stat_display/SingleStatDisplay.gd")

@export var melee_attack: StatDisplay
@export var ranged_attack: StatDisplay 
@export var melee_defense: StatDisplay 
@export var ranged_defense: StatDisplay 
@export var speed: StatDisplay 

func add(stat: StatManager.Stats, amount: float) -> void:
	match stat:
		StatManager.Stats.ATTACK:
			update_nibs(melee_attack, $MeleeAttack, amount)
			update_nibs(ranged_attack, $RangedAttack, amount)
		StatManager.Stats.MELEE_ATTACK:
			update_nibs(melee_attack, $MeleeAttack, amount)
		StatManager.Stats.RANGED_ATTACK:
			update_nibs(ranged_attack, $RangedAttack, amount)
		StatManager.Stats.DEFENSE:
			update_nibs(melee_defense, $MeleeDefense, amount)
			update_nibs(ranged_defense, $RangedDefense, amount)
		StatManager.Stats.MELEE_DEFENSE:
			update_nibs(melee_defense, $MeleeDefense, amount)
		StatManager.Stats.RANGED_DEFENSE:
			update_nibs(ranged_defense, $RangedDefense, amount)
		StatManager.Stats.SPEED: 
			update_nibs(speed, $Speed, amount)
		StatManager.Stats.MELEE:
			update_nibs(melee_attack, $MeleeAttack, amount)
			update_nibs(melee_defense, $MeleeDefense, amount)
		StatManager.Stats.RANGED:
			update_nibs(ranged_attack, $RangedAttack, amount)
			update_nibs(ranged_defense, $RangedDefense, amount)

func update_nibs(display: StatDisplay, rect: TextureRect, mod: float=1) -> void:
	var text := rect.tooltip_text
	var index := text.rfind(":")
	rect.tooltip_text = text.substr(0, index) + ": " + str(mod * 100) + "%"

	display.update(mod)
