extends Menu

signal open_spell_menu(index: int, actor: BattleActor)
signal open_equipment_menu(index: int, actor: BattleActor)

@export var CharacterScreen: PackedScene

var _player: Node3D

func setup(player: Node3D) -> void:
	_player = player
	_player.team_changed.connect(_setup_team)

	if not Settings.player_name.is_empty():
		_player.battle_actor.name = Settings.player_name

	$Player.setup(_player.battle_actor, true)
	_player.actor_changed.connect($Player.setup.bind(true))

	if not $Player.open_equipment_menu.is_connected(_on_open_equipment_menu):
		$Player.open_equipment_menu.connect(_on_open_equipment_menu.bind(_player.battle_actor))
	if not $Player.open_spell_menu.is_connected(_on_open_spell_menu):
		$Player.open_spell_menu.connect(_on_open_spell_menu.bind(_player.battle_actor))

	_setup_team(_player.team)


func _setup_team(team: Array[BattleActor]) -> void:
	for screen in get_children():
		if screen == $Player: continue
		remove_child(screen)

	for actor in team:
		if actor == _player.battle_actor: continue
		var screen := CharacterScreen.instantiate()
		screen.setup(actor)
		screen.name = actor.name
		screen.open_equipment_menu.connect(_on_open_equipment_menu.bind(actor))
		screen.open_spell_menu.connect(_on_open_spell_menu.bind(actor))
		add_child(screen)


func _on_open_spell_menu(index: int, actor: BattleActor) -> void:
	open_spell_menu.emit(index, actor)


func _on_open_equipment_menu(id: int, actor: BattleActor) -> void:
	open_equipment_menu.emit(id, actor)
