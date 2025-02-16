extends ModEquipmentEffect
class_name BiasMod 

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _bias: String = "blank":
	set(value):
		_bias = value
		bias = ElementManager.get_element_from_name(value)
var bias: ElementalType = ElementManager.Blank:
	set(value):
		if value == null:
			value = ElementManager.Blank
		bias = value

@export var reversion_threshold := -1.0

var _prev_bias: ElementalType
var _prev_threshold: float

#override
func equip(actor: BattleActor) -> void:
	if not bias.is_blank():
		_prev_bias = actor.elemental_bias
		actor.elemental_bias = bias
	if reversion_threshold != -1:
		_prev_threshold = actor.bias_reversion_threshold
		actor.bias_reversion_threshold = reversion_threshold

#override
func unequip(actor: BattleActor) -> void:
	if not bias.is_blank():
		actor.elemental_bias = _prev_bias
	if reversion_threshold != -1:
		actor.bias_reversion_threshold = _prev_threshold
