extends Area3D

signal player_defeated_enemy()
signal enemy_defeated_player()
signal player_ran()

static var rng := RandomNumberGenerator.new():
	set(val):
		rng = val
		rng.seed = Settings.random_seed

@export var weighted_enemy_pool: Dictionary[PackedScene, float] = {}
var _enemy_pool: Array[PackedScene]
var _enemy_weights: Array[float]

@export var level_range := Vector2i(1, 1)
@export var team_count_range := Vector2i(1, 3)
@export var spawn_frequency_range := Vector2(1.0, 5.0)
@export var xp_range := Vector2i(10, 50)
@export var max_spawn_count := 10

var _enemy_count := 0

func _ready() -> void:
	# Done manually jsut in case Dict.keys() and Dict.values() ever return objs in diff order.
	_enemy_pool = []
	_enemy_weights = []
	for key in weighted_enemy_pool:
		_enemy_pool.append(key)
		_enemy_weights.append(weighted_enemy_pool[key])


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


func _create_wild_enemy_actor() -> WildEnemyActor:
	var enemyLeader: WildEnemyActor = _get_rand_enemy()
	enemyLeader.ai.reward_xp = randi_range(xp_range.x, xp_range.y)
	var teamCount := randi_range(team_count_range.x, team_count_range.y)

	for i in teamCount - 1:
		enemyLeader.add_ally(_get_rand_enemy)

	for i in len(enemyLeader.team):
		var lvl := randi_range(level_range.x, level_range.y)
		enemyLeader.set_level(lvl, i)

	enemyLeader.select_reward_items()
	return enemyLeader

func _get_rand_enemy() -> WildEnemyActor:
	return _enemy_pool[rng.rand_weighted(_enemy_weights)].instantiate().duplicate()

func _restart_timer() -> void:
	var freq := randf_range(spawn_frequency_range.x, spawn_frequency_range.y)
	if $Timer.is_inside_tree():
		$Timer.start(freq)


func spawn() -> void:
	var enemy := _create_wild_enemy_actor()
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
