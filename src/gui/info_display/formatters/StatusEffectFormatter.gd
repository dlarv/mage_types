extends Formatter 

@export var name_label: RichTextLabel
@export var details_label: RichTextLabel
@export var icon_parent: Control 

func display(effect: Variant, limitInfo:=false) -> void:
	super.display(effect)

	if effect.icon != null:
		icon_parent.add_child(effect.instantiate_icon())
	
	name_label.clear()
	name_label.append_text(effect.name)

	if effect is PhobiaEffect:
		details_label.append_text("Deals 10%% damage every time this combatant becomes [el]%s[/el]." 
				% effect.element)
	details_label.append_text(effect.description)
