@tool
extends Area3D
class_name EnemyActor 

@export var shape: Shape3D:
	get:
		if _collision_shape == null: return null
		return _collision_shape.shape
	set(value):
		if _collision_shape == null: return null
		_collision_shape.shape = value

@export var ai: OpponentController 
@export var team: Array[BattleActor]
@export var fight_on_collision := true

# Prevents this enemy from immediately starting a new battle once the first has ended.
var _allow_collisions := true
var _collision_shape: CollisionShape3D 


func _enter_tree():
	_collision_shape = get_node("CollisionShape3D")
	_collision_shape.disabled = not fight_on_collision
	
func set_size(size: Variant, height: float) -> void:
	if size is float:
		size = Vector3(size, size, size)
	_collision_shape.scale = size
	_collision_shape.position.y = height

func _on_body_exited(body:Node3D) -> void:
	if can_process() and body is Player:
		_allow_collisions = true


func _on_body_entered(body:Node3D) -> void:
	if not _allow_collisions: return

	if body is Player:
		_allow_collisions = false
		body.call_deferred("start_battle", self)

