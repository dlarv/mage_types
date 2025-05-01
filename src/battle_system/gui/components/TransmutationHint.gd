extends PanelContainer

@export var attack_element_1: ColorRect
@export var attack_element_2: ColorRect
@export var attack_element_3: ColorRect
@export var internal_element_1: ColorRect
@export var internal_element_2: ColorRect
@export var internal_element_3: ColorRect

var _pos3D: Vector3
var is_active := false 

func setup(target: BattleActor, attack: _BattleAction, pos3D: Vector3) -> void:
	var attackElement := attack.element
	_pos3D = pos3D

	var result1 = ElementManager.get_matchup(target.element2, attackElement)
	attack_element_1.set_element(target.element2)
	attack_element_2.set_element(attackElement)
	attack_element_3.set_element(result1)

	var result2 = ElementManager.get_matchup(target.element1, result1)
	internal_element_1.set_element(target.element1)
	internal_element_2.set_element(result1)
	internal_element_3.set_element(result2)


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
	# var pos2D := cam.unproject_position(_pos3D)
	var pos2D := get_viewport().get_mouse_position() - Vector2(0, size.y)

	global_position = pos2D
