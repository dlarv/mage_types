extends PanelContainer

@export var primary_element_1: ColorRect
@export var primary_elemen_2: ColorRect
@export var secondary_element_1: ColorRect
@export var secondary_element_2: ColorRect
@export var attack_element_1: ColorRect
@export var attack_element_2: ColorRect
@export var result_element_1: ColorRect
@export var result_element_2: ColorRect
@export var result_element_3: ColorRect

func setup(actor: BattleActor, attackElement: ElementalType) -> void:
	var result1 = ElementManager.get_matchup(actor.element1, attackElement)
	attack_element_1.set_element(attackElement)
	primary_element_1.set_element(actor.element1)
	result_element_1.set_element(result1)

	var result2 = ElementManager.get_matchup(actor.element2, attackElement)
	secondary_element_1.set_element(actor.element2)
	attack_element_2.set_element(attackElement)
	result_element_2.set_element(result2)

	var primary = result1 if result1 != null and not result1.is_blank() else actor.element1
	var secondary = result2 if result2 != null and not result2.is_blank() else actor.element2

	var result3 = ElementManager.get_matchup(primary, secondary)
	primary_elemen_2.set_element(primary)
	secondary_element_2.set_element(secondary)
	result_element_3.set_element(result3)
