@tool
extends "res://src/overworld/characters/Npc.gd"

enum Behavior { AGGRO, FLEE, PASSIVE }

@export var ball: PackedScene
@export var sense_range := 10.0

@export var speed := 2.0
@export var behavior := Behavior.AGGRO

var _spheres := 0
var _can_see_player := false
var _spawn_position := Vector3.ZERO

func _enter_tree() -> void:
	super._enter_tree()
	_spawn_position = global_position


func setup(team: Array[BattleActor], controller: OpponentController) -> void:
	for actor in team:
		_add_new_gradient_sprite(actor)
	
	$EnemyActor.ai = controller
	$EnemyActor.team = team
	
	$PlayerSensor/CollisionShape3D.shape = SphereShape3D.new()
	$PlayerSensor/CollisionShape3D.shape.radius = sense_range


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not _can_see_player: 
		state.linear_velocity = Vector3.ZERO
		return

	if $NavigationAgent3D.is_target_reachable():
		var nextPosition: Vector3 = $NavigationAgent3D.get_next_path_position()
		state.linear_velocity = global_position.direction_to(nextPosition) * speed


func _add_new_gradient_sprite(actor: BattleActor) -> void:
	_spheres += 1
	var mesh := ball.instantiate()
	mesh.setup(actor)

	mesh.position.y = 1 * _spheres
	add_child(mesh)


# Override
func react(e: ElementalType, randVal:=-2) -> bool:
	if randVal == _rand_val: return false
	_rand_val = randVal

	for actor: BattleActor in $EnemyActor.team:
		var e1 := ElementManager.get_matchup(actor.element1, e)
		if e1:
			actor.set_element(0, e1)

		var e2 := ElementManager.get_matchup(actor.element2, e)
		if e2:
			actor.set_element(1, e2)

	return true


func _on_player_sensor_body_exited(body:Node3D) -> void:
	_can_see_player = false 
	_player = null


func _on_player_sensor_body_entered(body:Node3D) -> void:
	_can_see_player = true
	_on_nav_recalc_timer_timeout()
	_player = body


func _on_body_entered(body:Node3D) -> void:
	if not body.is_in_group("player"): return
	if not _on_cooldown:
		get_tree().call_group("wild_enemies", "_start_battle_cooldown")
		body.call_deferred("start_battle", self)
		queue_free()


func _on_nav_recalc_timer_timeout() -> void:
	if not _can_see_player: return

	match behavior:
		Behavior.AGGRO:
			$NavigationAgent3D.set_target_position(_player.global_position)
		Behavior.FLEE:
			var target := global_position - _player.global_position
			$NavigationAgent3D.set_target_position(target.normalized() + global_position)
			
		Behavior.PASSIVE,_:
			pass

	$NavRecalcTimer.start()

	
