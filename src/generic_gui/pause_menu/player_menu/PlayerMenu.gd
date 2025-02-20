extends Menu

signal open_spell_menu(index: int, actor: BattleActor)
signal open_equipment_menu(actor: BattleActor)

@export var CharacterScreen: PackedScene

var _player: Player

func _ready() -> void:
	var p =get_tree().get_nodes_in_group("player") 
	if len(p) > 0:
		setup(p[0])

func setup(player: Player) -> void:
	_player = player
	$Player.setup(player.battle_actor)
	$Player.open_equipment_menu.connect(_on_open_equipment_menu.bind(_player.battle_actor))
	$Player.open_spell_menu.connect(_on_open_spell_menu.bind(_player.battle_actor))

	for actor in player.team:
		var screen := CharacterScreen.instantiate()
		screen.setup(actor)
		screen.name = actor.name
		screen.open_equipment_menu.connect(_on_open_equipment_menu.bind(actor))
		screen.open_spell_menu.connect(_on_open_spell_menu.bind(actor))
		add_child(screen)

func _on_open_spell_menu(index: int, actor: BattleActor) -> void:
	open_spell_menu.emit(index, actor)

func _on_open_equipment_menu(actor: BattleActor) -> void:
	open_equipment_menu.emit(actor)
