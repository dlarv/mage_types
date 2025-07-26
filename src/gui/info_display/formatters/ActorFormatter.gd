extends Formatter

@export var name_label: Label
@export var element1_icon: ElementIcon
@export var element2_icon: ElementIcon
@export var bias_icon: ElementIcon
@export var hp_label: Label
@export var status_effect_vbox: VBoxContainer
@export var effects_label: RichTextLabel
@export var melee_attack_label: Label
@export var ranged_attack_label: Label
@export var melee_defense_label: Label
@export var ranged_defense_label: Label
@export var speed_label: Label
@export var evasion_label: Label
@export var equipment_hbox: HBoxContainer
@export var attacks_label: RichTextLabel

func display(obj: Variant, limitInfo:=false) -> void:
	super.display(obj)

	effects_label.clear()
	attacks_label.clear()
	equipment_hbox.get_child(0).text = ""
	equipment_hbox.get_child(1).clear()

	# Basic info.
	name_label.text = obj.name
	element1_icon.element = obj.element1
	element2_icon.element = obj.element2

	if obj.alignment and not obj.alignment.is_blank():
		bias_icon.show()
		bias_icon.element = obj.alignment
	else:
		bias_icon.hide()

	hp_label.text = "%d/%d" % [obj.current_hp, obj.hp]

	display_stats(obj)

	# Status effects.
	var effects: Array[StatusEffect] = obj.list_status_effects()
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

	# Equipment
	if obj.equipment:
		equipment_hbox.show()
		equipment_hbox.get_child(0).text = obj.equipment.name
		equipment_hbox.get_child(1).append_text(obj.equipment.details)
	else:
		equipment_hbox.hide()
	
	for attack: Attack in obj.attacks:
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
