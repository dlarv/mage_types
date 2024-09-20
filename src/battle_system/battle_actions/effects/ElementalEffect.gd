@tool
extends StatusEffect 
class_name ElementalEffect 

@export
var Element : ElementalType 

# override
func ApplyEffect(user, target=null, action=null):
	var output = super.ApplyEffect(user, target, action)
	return output.replace("{element}", Element.Name)

# override
func InstantiateIcon():
	var output = super.InstantiateIcon()
	output.color = Element.MainColor
	return output
