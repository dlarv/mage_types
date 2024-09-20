@tool
extends AttackEffect 
class_name TransmutateAttackEffect 

@export
var Element: ElementalType 
@export_range(0, 1)
var ElementId : int 

#override
func ApplyEffect(user, target=null, action=null):
	return target.SetElement(ElementId, Element)
