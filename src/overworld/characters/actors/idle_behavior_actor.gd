extends Node3D

@export var track_player_distance: bool

var _player: Node3D
var _player_distance: float

func _ready() -> void:
	if track_player_distance:
		_player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	if track_player_distance and _player:
		_player_distance = global_position.distance_to(_player.global_position)
