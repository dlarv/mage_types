extends Formatter

@export var name_label: Label
@export var element1_icon: ElementIcon
@export var element2_icon: ElementIcon
@export var bias_icon: ElementIcon
@export var hp_label: Label
@export var cost_label: RichTextLabel
@export var status_effect_vbox: VBoxContainer
@export var effects_label: RichTextLabel
@export var melee_attack_label: Label
@export var ranged_attack_label: Label
@export var melee_defense_label: Label
@export var ranged_defense_label: Label
@export var speed_label: Label
@export var evasion_label: Label
@export var attacks_label: RichTextLabel

func display(obj: Variant, limitInfo:=false) -> void:
	super.display(obj)

	effects_label.clear()
	cost_label.clear()
	attacks_label.clear()

	# Basic info.
	name_label.text = obj.name
	element1_icon.element = obj.element1
	element2_icon.element = obj.element2
	bias_icon.element = obj.alignment
	hp_label.text = "%d/%d" % [obj.current_hp, obj.hp]

	display_stats(obj)

	# Status effects.
	var effects = obj.list_status_effects()
	if len(effects) == 0:
		status_effect_vbox.hide()
	else:
		status_effect_vbox.show()
		for effect in effects:
			effects_label.push_meta(effect)
			effects_label.append_text(effect.name)
			effects_label.pop() # Pop meta
			effects_label.append_text(": %d turns remaining." % effect.duration)
			effects_label.newline()
	
	for attack in obj.attacks:
		if attack == null: continue
		attacks_label.push_meta(attack)
		attacks_label.append_text(attack.name)
		attacks_label.pop() # Pop meta
		attacks_label.newline()

func display_stats(actor: BattleActor) -> void:
	var template := "%d = (%d) * (%d%%)"
	var statManager := actor.stat_manager
	var mod: float
	var base: float
	var actual: float

	base = statManager.get_base_stat(StatManager.Stats.MELEE_ATTACK)
	mod = statManager.get_stat_mod(StatManager.Stats.MELEE_ATTACK) * 100
	actual = statManager.melee_attack
	melee_attack_label.text = template % [int(actual), int(base), int(mod)]

	base = statManager.get_base_stat(StatManager.Stats.RANGED_ATTACK)
	mod = statManager.get_stat_mod(StatManager.Stats.RANGED_ATTACK) * 100
	actual = statManager.ranged_attack
	ranged_attack_label.text = template % [int(actual), int(base), int(mod)]

	base = statManager.get_base_stat(StatManager.Stats.MELEE_DEFENSE)
	mod = statManager.get_stat_mod(StatManager.Stats.MELEE_DEFENSE) * 100
	actual = statManager.melee_defense
	melee_defense_label.text = template % [int(actual), int(base), int(mod)]
	
	base = statManager.get_base_stat(StatManager.Stats.RANGED_DEFENSE)
	mod = statManager.get_stat_mod(StatManager.Stats.RANGED_DEFENSE) * 100
	actual = statManager.ranged_defense
	ranged_defense_label.text = template % [int(actual), int(base), int(mod)]

	base = statManager.get_base_stat(StatManager.Stats.SPEED)
	mod = statManager.get_stat_mod(StatManager.Stats.SPEED) * 100
	actual = statManager.speed
	speed_label.text = template % [int(actual), int(base), int(mod)]
