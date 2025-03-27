extends Formatter 

@export var name_label: RichTextLabel
@export var details_label: RichTextLabel
@export var icon_parent: Control 

func display(effect: Variant, limitInfo:=false) -> void:
	super.display(effect)

	if effect.icon != null:
		icon_parent.add_child(effect.instantiate_icon())
	
	name_label.clear()
	name_label.append_text(effect.get_full_name())
	# if effect is ElementalEffect:
	# 	# append_elemental_color(name_label, effect.element)
	# 	# name_label.append_text("-%s" % effect.name)
	# 	name_label.append_text(effect.get_full_name())
	#
	#
	# elif effect is StatChange:
	# 	name_label.append_text(effect.get_full_name())
	# elif effect is StatusEffect:
	# 	name_label.append_text(effect.name)

	details_label.append_text(effect.description)
