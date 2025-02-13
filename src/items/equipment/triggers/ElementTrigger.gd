@tool
extends EquipmentTrigger
class_name ElementTrigger

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType:
	set(value):
		element = value
		resource_name = "%s Trigger" % element.name
@export_enum("primary", "secondary", "either")
var index := "either"

var _bonus: EquipmentBonus
var _actor: BattleActor

#override
func equip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	_bonus = bonus
	_actor = actor
	if not actor.element_changed.is_connected(_on_element_changed):
		actor.element_changed.connect(_on_element_changed)

#override
func unequip(actor: BattleActor, bonus: EquipmentBonus) -> void:
	_bonus = null 
	_actor = null
	if actor.element_changed.is_connected(_on_element_changed):
		actor.element_changed.disconnect(_on_element_changed)

func _on_element_changed(id: int, e: ElementalType, actor) -> void:
	if (index == "primary" and id != 0) or (index == "secondary" and id != 1): return
	if not element.is_blank() and element != e: return
	_bonus.apply_to(_actor)
	activated.emit("")

