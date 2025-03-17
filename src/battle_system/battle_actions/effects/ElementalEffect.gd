@tool
extends StatusEffect 
class_name ElementalEffect 

# override
func apply_effect(user: BattleActor, target: BattleActor=null, action: _BattleAction=null, effectiveness:=1.0, element: ElementalType =ElementManager.Blank):
	# If self.element is applied in the editor, each time this effect is used will have to be made into
	# a unique instance. Defining it here allows the creation and editing of new attacks easier.
	# var effect = duplicate()
	# effect.element = action.element
	var output = super.apply_effect(user, target, action, effectiveness, element)
	return output.replace("{element}", element.name)

# override
func instantiate_icon() -> Node:
	var output = super.instantiate_icon()
	output.modulate = element.main_color
	output.get_node("Button").tooltip_text = "%s-%s" % [ element.name, name ] 
	return output
