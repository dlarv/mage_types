extends Area3D

signal player_defeated_enemy()
signal enemy_defeated_player()
signal player_ran()

const BaseEnemyActor := preload("res://src/overworld/enemies/wild_enemy_actor.tscn")

@export var battle_actors: Array[BattleActor]
@export var controllers: Array[OpponentController]

@export var level_range := Vector2i(1, 1)
@export var team_count_range := Vector2i(1, 3)
@export var spawn_frequency_range := Vector2(1.0, 5.0)
@export var max_spawn_count := 10

var _enemies := []

func _process(delta: float) -> void:
	if not visible or len(_enemies) >= max_spawn_count: return
	if $Timer.is_stopped(): 
		spawn()
		_restart_timer()

func _get_rand_point() -> Vector3:
	if not $CollisionShape3D: return Vector3(0, 0, 0)
	var spawnArea: Vector3 = $CollisionShape3D.shape.extents 
	var a: Vector3 = $CollisionShape3D.position - spawnArea
	var b: Vector3 = $CollisionShape3D.position + spawnArea
	return Vector3(
		randf_range(a.x, b.x),
		a.y,
		randf_range(a.z, b.z)
	)

func _get_rand_enemy() -> Node3D:
	var actor := BaseEnemyActor.instantiate()

	var team: Array[BattleActor] = []
	var count := randi_range(team_count_range.x, team_count_range.y)
	for i in range(count):
		var battleActor: BattleActor = battle_actors.pick_random().duplicate(true)
		battleActor.level = randi_range(level_range.x, level_range.y)
		team.append(battleActor)
	
	var controller: OpponentController = controllers.pick_random()
	if not controller.battle_ended.is_connected(_on_battle_ended):
		controller.battle_ended.connect(_on_battle_ended)

	actor.setup(team, controller)
	return actor

func _restart_timer() -> void:
	var freq := randf_range(spawn_frequency_range.x, spawn_frequency_range.y)
	if $Timer.is_inside_tree():
		$Timer.start(freq)

func spawn() -> void:
	var enemy := _get_rand_enemy()
	var pos := _get_rand_point()
	add_child(enemy)
	enemy.position = pos 

	_enemies.append(enemy)

	enemy.tree_exited.connect(func() -> void:
		var index := _enemies.find(enemy)
		_enemies.remove_at(index)
		_restart_timer())

func _on_battle_ended(endState: Battle.EndState) -> void:
	match endState:
		Battle.EndState.WON:
			player_defeated_enemy.emit()
		Battle.EndState.DEFEATED:
			enemy_defeated_player.emit()
		Battle.EndState.FLED:
			player_ran.emit()
