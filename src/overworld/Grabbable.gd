@tool
extends Node3D
class_name Grabbable

signal grabbed(obj: Node3D, player: Node3D)
signal dropped(obj: Node3D, player: Node3D)

@export var label_offset: Vector3
var _label: Label
var _player: Node3D

func _enter_tree():
	# Interaction prompt
	_label = get_node("Label")
	if not Engine.is_editor_hint():
		# Display what button the player must press to talk.
		var actions := InputMap.action_get_events("interact")
		_label.text = "Press %s" % actions[0].as_text().split(" ")[0]

func _unhandled_input(event: InputEvent) -> void:
	if not _label.visible or _player == null: return

	if event.is_action_pressed("interact"):
		get_window().set_input_as_handled()
		grabbed.emit(self, _player)

func _physics_process(delta: float) -> void:
	if not _label.visible: return
	# Adjust position of label to be floating above character's head.
	var pos3D := global_position + label_offset
	var cam := get_viewport().get_camera_3d()
	var pos2D := cam.unproject_position(pos3D)
	_label.global_position = pos2D
	_label.visible = not cam.is_position_behind(pos3D)


func _on_body_entered(body:Node3D) -> void:
	if not body.is_in_group("player"): return
	_player = body
	_label.show()


func _on_body_exited(body:Node3D) -> void:
	if not body.is_in_group("player"): return
	_label.hide()
	dropped.emit(self, _player)
	_player = null


	
