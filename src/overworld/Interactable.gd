@tool
extends Node3D
class_name Interactable

signal interacted(obj: Node3D)

@export var label_offset: Vector3
@export var scaling_factor := 1.0:
	set(val):
		scaling_factor = val
		$Area3D/CollisionShape3D.shape = $Area3D/CollisionShape3D.shape.duplicate(true)
		$Area3D/CollisionShape3D.shape.radius = scaling_factor * base_size

@export var base_size := 1.0

var disabled := false
var _label: Label
var _player: Node3D

func _enter_tree():
	# Interaction prompt
	_label = get_node("Label")
	if not Engine.is_editor_hint():
		# Display what button the player must press to talk.
		var actions := InputMap.action_get_events("interact")
		_label.text = "Press %s" % actions[0].as_text().split(" ")[0]


func _input(event: InputEvent) -> void:
	if disabled or not _label.visible or _player == null: return

	if event.is_action_released("interact"):
		interacted.emit(self)
		var n = name
		if "puzzle_name" in get_parent():
			n = get_parent().puzzle_name
		Logger.append_log(Logger.LogType.PUZZLE, "Player used Interactable(%s)." % n)


func _physics_process(delta: float) -> void:
	if not _label.visible: return
	# Adjust position of label to be floating above character's head.
	var pos3D := global_position + label_offset
	var cam := get_viewport().get_camera_3d()
	var pos2D := cam.unproject_position(pos3D)
	_label.global_position = pos2D
	_label.visible = not cam.is_position_behind(pos3D)


func _on_body_entered(body:Node3D) -> void:
	if disabled: return
	# Used to differentiate between player and player when dragging object.
	if not body.is_in_group("player") or not body.in_control: return

	# Prevent player from picking up object, if they are already holding something.
	if body.held_object and body.held_object != get_parent(): 
		var n = name
		if "puzzle_name" in get_parent():
			n = get_parent().puzzle_name
		Logger.append_log(Logger.LogType.PUZZLE, 
				"Player collided with Interactable(%s), but could not pick it up, as they were already holding %s." 
				% [n, body.held_object.name])
		return

	_player = body
	_label.show()


func _on_body_exited(body:Node3D) -> void:
	if disabled: return
	# Used to differentiate between player and player when dragging object.
	if not body.is_in_group("player") or not body.in_control: return
	_label.hide()
	_player = null


func set_disabled(val: bool) -> void:
	disabled = val
	if disabled:
		_label.hide()
		_player = null

## Used when player tries to pick up two objects at once.
## Without this, they'll get teleported to the second object after dropping the first.
func ignore() -> void:
	_label.hide()
	_player = null
