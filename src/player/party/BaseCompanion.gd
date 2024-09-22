extends CharacterBody3D 
class_name BaseCompanion 

@export
var player_target : Node3D 
@export
var battle_actor : BattleActor 
@export
var speed : float 
@export
var distance_to_player : float 
@export
var max_distance : float = 10

func _physics_process(delta: float) -> void:
	if player_target == null: return
	# See if companion is within target distance.
	var playerPos = player_target.global_position
	var distance = playerPos.distance_to(global_position)
	if distance < max_distance and velocity == Vector3.ZERO and distance <= distance_to_player:
		velocity = Vector3.ZERO
		return

	var vel = global_position.direction_to(playerPos)
	vel.y = 0
	vel *= Vector3(speed, 0, speed)
	velocity = vel
	move_and_slide()
