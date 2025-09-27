extends Area3D

signal player_defeated_enemy()
signal enemy_defeated_player()
signal player_ran()

@export var enemy_pool: Array[PackedScene] = []

@export var level_range := Vector2i(1, 1)
@export var team_count_range := Vector2i(1, 3)
@export var spawn_frequency_range := Vector2(1.0, 5.0)
@export var max_spawn_count := 10

var _enemy_count := 0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if not visible or _enemy_count >= max_spawn_count: return
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


func _get_rand_enemy() -> WildEnemyActor:
	var enemyLeader: WildEnemyActor = enemy_pool.pick_random().instantiate().duplicate()
	var teamCount := randi_range(team_count_range.x, team_count_range.y)

	for i in teamCount - 1:
		enemyLeader.add_ally(enemy_pool.pick_random().instantiate())

	for i in len(enemyLeader.team):
		var lvl := randi_range(level_range.x, level_range.y)
		enemyLeader.set_level(lvl, i)

	return enemyLeader


func _restart_timer() -> void:
	var freq := randf_range(spawn_frequency_range.x, spawn_frequency_range.y)
	if $Timer.is_inside_tree():
		$Timer.start(freq)


func spawn() -> void:
	var enemy := _get_rand_enemy()
	var pos := _get_rand_point()
	add_child(enemy)
	enemy.position = pos 

	_enemy_count += 1

	enemy.tree_exited.connect(func() -> void:
		_enemy_count -= 1
		_restart_timer())


func _on_battle_ended(endState: Battle.EndState) -> void:
	match endState:
		Battle.EndState.WON:
			player_defeated_enemy.emit()
		Battle.EndState.DEFEATED:
			enemy_defeated_player.emit()
		Battle.EndState.FLED:
			player_ran.emit()
