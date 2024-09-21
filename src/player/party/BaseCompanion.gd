@tool
extends CharacterBody3D 
class_name BaseCompanion 

@export
var PlayerTarget : Node3D 
@export
var battle_actor : BattleActor 
@export
var Speed : float 
@export
var DistanceToPlayer : float 
@export
var max_distance : float = 10

func _physics_process(delta: float) -> void:
	# See if companion is within target distance.
	var playerPos = PlayerTarget.global_position 
	var distance = playerPos.distance_to(global_position)
	if distance < max_distance and velocity == Vector3.ZERO and distance <= DistanceToPlayer:
		velocity = Vector3.ZERO
		return

	var vel = global_position.direction_to(playerPos)
	vel.y = 0
	vel *= Vector3(Speed, 0, Speed)
	velocity = vel
	move_and_slide()
