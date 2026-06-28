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
## Message to show player when they approach this object.
## Message will be formatted {button_prompt} to {message_override}
@export var message_override := ""

var disabled := false
var force := false
var player: Node3D

func _enter_tree() -> void:
	disabled = not visible
	# Interaction prompt
	if not Engine.is_editor_hint():
		# Display what button the player must press to talk.
		var actions := InputMap.action_get_events("interact")
		var msg := ""
		if not message_override.is_empty():
			msg = "to %s" % message_override
		$Label3D.text = "Press %s %s" % [actions[0].as_text().split(" ")[0], msg]
		$Label3D.position = label_offset


func _input(event: InputEvent) -> void:
	if disabled or not $Label3D.visible or player == null: return

	if event.is_action_released("interact"):
		interacted.emit(self)
		var n: String = name
		if "puzzle_name" in get_parent():
			n = get_parent().puzzle_name
		MyLogger.append_puzzle_log("Player used Interactable(%s)." % n)


# func _physics_process(delta: float) -> void:
# 	if not $Label3D.visible: return
# 	# Adjust position of label to be floating above character's head.
# 	var pos3D := global_position + label_offset
# 	var cam := get_viewport().get_camera_3d()
# 	var pos2D := cam.unproject_position(pos3D)
# 	$Label3D.global_position = pos2D
# 	$Label3D.visible = not cam.is_position_behind(pos3D)


func _on_body_entered(body:Node3D) -> void:
	if disabled: return
	if not body.is_in_group("player"): return
	# If player is already dragging another object, ignore.
	if body.draggable != null and body.draggable != get_parent(): return
	player = body
	$Label3D.show()


func _on_body_exited(body:Node3D) -> void:
	if disabled or force: return
	if not body.is_in_group("player"): return
	$Label3D.hide()
	player = null


func set_disabled(val: bool) -> void:
	disabled = val
	if disabled:
		$Label3D.hide()
		player = null

## Used when player tries to pick up two objects at once.
## Without this, they'll get teleported to the second object after dropping the first.
func ignore() -> void:
	$Label3D.hide()
	player = null


func toggle_force_show(val: bool) -> void:
	force = val
	$Label3D.visible = val


func _on_visibility_changed() -> void:
	disabled = not visible
