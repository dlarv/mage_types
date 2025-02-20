extends Menu

@export var CharacterScreen: PackedScene

var _player: Player

func _ready() -> void:
	var p =get_tree().get_nodes_in_group("player") 
	if len(p) > 0:
		setup(p[0])

func setup(player: Player) -> void:
	_player = player
	$Player.setup(player.battle_actor)

	for actor in player.team:
		var screen := CharacterScreen.instantiate()
		screen.setup(actor)
		screen.name = actor.name
		add_child(screen)
