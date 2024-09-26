extends Formatter

@export
var name_label: Label
@export
var element1_icon: ElementIcon
@export
var element2_icon: ElementIcon
@export
var bias_icon: ElementIcon
@export
var hp_label: Label
@export
var mana_label: Label
@export
var status_effect_vbox: VBoxContainer
@export
var effects_label: RichTextLabel
@export
var melee_attack_label: Label
@export
var ranged_attack_label: Label
@export
var melee_defense_label: Label
@export
var ranged_defense_label: Label
@export
var speed_label: Label
@export
var evasion_label: Label
@export
var attacks_label: RichTextLabel

func display(obj: BattleActor):
	super.display(obj)
	name_label.text = obj.name
	element1_icon.element = obj.element1
	element2_icon.element = obj.element2
	bias_icon.element = obj.elemental_bias

	hp_label.text = "%d/%d" % [obj.current_hp, obj.hp]
	mana_label.text = "%d/%d" % [obj.current_mana, obj.mana]

	var effects = obj.list_status_effects()
	if len(effects) == 0:
		status_effect_vbox.hide()
	else:
		status_effect_vbox.show()
		for effect in effects:
			effects_label.push_meta(effect)
			effects_label.append_text(effect.get_full_name())
			effects_label.pop() # Pop meta
			effects_label.append_text(": %d turns remaining." % effect.duration)
			effects_label.newline()
	
	for attack in obj.attacks:
		attacks_label.push_meta(attack)
		attacks_label.append_text(attack.name)
		attacks_label.pop() # Pop meta
		attacks_label.newline()


	
