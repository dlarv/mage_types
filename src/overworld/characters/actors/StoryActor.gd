@tool
extends Area3D
class_name StoryActor
## Allows a character to participate in the game's story, mostly through dialog .

signal dialog_started(dialog_id, data)

var _label: Label
var _collision_shape: CollisionShape3D

@export var actor_name: String
@export var shape: Shape3D:
	get:
		if _collision_shape == null: return null
		return _collision_shape.shape
	set(value):
		if _collision_shape == null: return
		_collision_shape.shape = value

@export var offset: Vector3
@export var dialog_ids: Array[String]
@export var current_id: int = 0

var _show_label := false

func _enter_tree():
	_collision_shape = get_node("DialogCollider")
	_label = get_node("Label")
	if not Engine.is_editor_hint():
		# Display what button the player must press to talk.
		var actions := InputMap.action_get_events("interact")
		_label.text = "Press %s" % actions[0].as_text().split(" ")[0]


func _unhandled_input(event: InputEvent) -> void:
	if not _show_label: return

	if event.is_action_pressed("interact"):
		start_dialog()

# Virtual
func start_dialog():
	dialog_started.emit(dialog_ids[current_id], null)
	


func _physics_process(delta: float) -> void:
	if not _show_label: return
	var pos3D := global_position + offset
	var cam := get_viewport().get_camera_3d()
	var pos2D := cam.unproject_position(pos3D)
	_label.global_position = pos2D
	_label.visible = not cam.is_position_behind(pos3D)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_show_label = true
		_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_show_label = false
		_label.visible = false
