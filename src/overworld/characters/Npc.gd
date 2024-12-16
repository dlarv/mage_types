@tool
extends Area3D

@export var label_offset: Vector3
var _label: Label

var _story_actor: StoryActor = null
var _vendor_actor: VendorActor = null
var _enemy_actor: EnemyActor = null
# Player or PhysicsPlayer
var _player: Variant

var _on_cooldown := false

func _enter_tree():
	# Interaction prompt
	_label = get_node("Label")
	if not Engine.is_editor_hint():
		# Display what button the player must press to talk.
		var actions := InputMap.action_get_events("interact")
		_label.text = "Press %s" % actions[0].as_text().split(" ")[0]

	for child in get_children():
		if child is VendorActor: 
			_vendor_actor = child
		elif child is StoryActor:
			_story_actor = child
		elif child is EnemyActor:
			_enemy_actor = child

func _unhandled_input(event: InputEvent) -> void:
	if not _label.visible or _player == null: return

	if event.is_action_pressed("interact"):
		if _story_actor != null:
			_player.call_deferred("start_dialog", _story_actor)
		else:
			_player.call_deferred("open_shop", _vendor_actor)
		_player = null
		_label.hide()

func _physics_process(delta: float) -> void:
	if not _label.visible: return
	# Adjust position of label to be floating above character's head.
	var pos3D := global_position + label_offset
	var cam := get_viewport().get_camera_3d()
	var pos2D := cam.unproject_position(pos3D)
	_label.global_position = pos2D
	_label.visible = not cam.is_position_behind(pos3D)


func _on_body_entered(body:Node3D) -> void:
	if not (body is Player or body is PhysicsPlayer): return

	if _story_actor != null or _vendor_actor != null: 
		_label.show()
		_player = body
	elif not _on_cooldown:
		get_tree().call_group("wild_enemies", "_start_battle_cooldown")
		body.call_deferred("start_battle", _enemy_actor)
			

func _on_body_exited(body:Node3D) -> void:
	if not (body is Player or body is PhysicsPlayer): return
	_label.hide()
	_player = null

## Called by OverworldConnector is this character is part of the "wild_enemies" group.
func _end_battle_cooldown() -> void:
	_on_cooldown = false 

func _start_battle_cooldown() -> void:
	_on_cooldown = true
