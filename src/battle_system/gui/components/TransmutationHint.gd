extends PanelContainer

@export
var primary_element1: ColorRect
@export
var primary_element2: ColorRect
@export
var secondary_element1: ColorRect
@export
var secondary_element2: ColorRect
@export
var attack_element1: ColorRect
@export
var attack_element2: ColorRect
@export
var result_element1: ColorRect
@export
var result_element2: ColorRect
@export
var result_element3: ColorRect

func setup(actor: BattleActor, attackElement: ElementalType) -> void:
	var result1 = ElementManager.get_matchup(actor.element1, attackElement)
	attack_element1.set_element(attackElement)
	primary_element1.set_element(actor.element1)
	result_element1.set_element(result1)

	var result2 = ElementManager.get_matchup(actor.element2, attackElement)
	secondary_element1.set_element(actor.element2)
	attack_element2.set_element(attackElement)
	result_element2.set_element(result2)

	var primary = result1 if result1 != null and not result1.is_blank() else actor.element1
	var secondary = result2 if result2 != null and not result2.is_blank() else actor.element2

	var result3 = ElementManager.get_matchup(primary, secondary)
	primary_element2.set_element(primary)
	secondary_element2.set_element(secondary)
	result_element3.set_element(result3)
