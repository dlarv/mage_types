extends "EasternCaveRoom.gd"

const Spawner := preload("res://src/overworld/enemies/Spawner.gd")

@export var base_level: int
@export var team_count_range: Vector2i
@export var max_spawn_count: int
@export var required_victories := 3

@onready var relay_1 := $Relay
@onready var relay_2 := $Relay2
@onready var relay_3 := $Relay3

var _level: int

func _ready() -> void:
	_puzzle_parent = $EastRoomFightChallenge/Chunk
	# _puzzle_parent.hide()


func set_difficulty(level: int) -> void:
	if level <= 0: return
	_puzzle_parent.show()
	_level = base_level + level - 1

	for child in _puzzle_parent.get_children():
		if not child is Spawner: continue
		var spawner = child
		spawner.team_count_range = team_count_range
		spawner.max_spawn_count = max_spawn_count
		spawner.level_range = Vector2i(_level, _level + 2)

		spawner.player_defeated_enemy.connect(func():
			await get_tree().create_timer(0.5).timeout
			required_victories -= 1
			match required_victories:
				2: relay_1._on_lock_opened(null)
				1: relay_2._on_lock_opened(null)
				0: 
					relay_3._on_lock_opened(null)
					spawner.hide()
			)
