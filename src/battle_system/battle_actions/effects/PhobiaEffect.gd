@tool
extends StatusEffect 
class_name PhobiaEffect 

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 
		_set_name("")

func _init():
	id = StatusEffectManager.StatusEffects.PHOBIC

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0):
	# If self.element is applied in the editor, each time this effect is used will have to be made into
	# a unique instance. Defining it here allows the creation and editing of new attacks easier.
	# var effect = duplicate()
	# effect.element = action.element
	var output = super.apply_effect(user, target, action, effectiveness)
	return output.replace("{element}", element.name)

# override
func instantiate_icon() -> Node:
	var output = super.instantiate_icon()
	output.modulate = element.main_color
	output.get_node("Button").tooltip_text = "%s-%s" % [ element, name ] 
	return output

# override
func _set_name(val: String) -> void:
	if element.is_blank():
		name = "Phobic"
	else:
		name = "%s-Phobic" % element
	resource_name = name

# override
func get_setup_potential(user: BattleActor, target: BattleActor, isFriendly: bool, dmg: float) -> float:
	return 1.0

# override
func _set_status_effect(val: StatusEffectManager.StatusEffects) -> void:
	id = StatusEffectManager.StatusEffects.PHOBIC
