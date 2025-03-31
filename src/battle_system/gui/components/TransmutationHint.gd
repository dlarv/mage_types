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

var _pos3D: Vector3
var is_active := false 

func setup(target: BattleActor, attack: _BattleAction, pos3D: Vector3) -> void:
	_pos3D = pos3D
	var attackElement := attack.element
	var result1 = ElementManager.get_matchup(target.element1, attackElement)
	attack_element_1.set_element(attackElement)
	primary_element_1.set_element(target.element1)
	result_element_1.set_element(result1)

	var result2 = ElementManager.get_matchup(target.element2, attackElement)
	secondary_element_1.set_element(target.element2)
	attack_element_2.set_element(attackElement)
	result_element_2.set_element(result2)

	var primary = result1 if result1 != null and not result1.is_blank() else target.element1
	var secondary = result2 if result2 != null and not result2.is_blank() else target.element2

	var result3 = ElementManager.get_matchup(primary, secondary)
	primary_elemen_2.set_element(primary)
	secondary_element_2.set_element(secondary)
	result_element_3.set_element(result3)

func activate():
	is_active = true
	show()

func deactivate():
	is_active = false
	hide()

func _process(delta: float) -> void:
	if not is_active: return
	# Adjust position of label to be floating above character's head.
	var cam := get_viewport().get_camera_3d()
	var pos2D := cam.unproject_position(_pos3D)
	global_position = pos2D
