@tool
extends Node

const ListItem := preload("ListItem.gd")

@export var ai: OpponentController
@export_tool_button("Collect Attacks")
var collect_attacks_button := func() -> void:
	for child in %AttackSelector.get_children(): %AttackSelector.remove_child(child)
	_traverse_attacks("res://data/battle_system/battle_actions/attacks/")
@export_tool_button("Collect Monsters")
var collect_monsters_button := _collect_monsters
var active_actor := BattleActor.new()

var opponents: Array[BattleActor] = []
var players: Array[BattleActor] = []

func _ready() -> void:
	UIManager.in_battle_mode = true
	_collect_monsters()
	%HpSpinBox.value_changed.connect(_on_stat_changed.bind(0))
	%SpeedSpinBox.value_changed.connect(_on_stat_changed.bind(1))
	%MASpinBox.value_changed.connect(_on_stat_changed.bind(2))
	%RASpinBox.value_changed.connect(_on_stat_changed.bind(3))
	%MDSpinBox.value_changed.connect(_on_stat_changed.bind(4))
	%RDSpinBox.value_changed.connect(_on_stat_changed.bind(5))
	%Name.text_changed.connect(func(value: String) -> void: 
		if active_actor == null: return
		active_actor.name = value)
	%Level.value_changed.connect(func(level: float) -> void:
		if active_actor == null: return
		var delta := level - active_actor.level
		%HpSpinBox.value = active_actor.stat_manager.hp * level
		%MASpinBox.value = active_actor.stat_manager._base_melee_attack * level
		%SpeedSpinBox.value = active_actor.stat_manager._base_speed * level
		%RASpinBox.value = active_actor.stat_manager._base_ranged_attack  * level
		%MDSpinBox.value = active_actor.stat_manager._base_melee_defense * level
		%RDSpinBox.value = active_actor.stat_manager._base_ranged_defense * level
	)
	_add_monster(UIManager.beastiary_menu.monsters[0][0])
	_on_add_player_button_pressed()
	_add_monster(UIManager.beastiary_menu.monsters[1][0])
	_on_add_opponent_button_pressed()


func _traverse_attacks(root: String) -> void:
	var dir := DirAccess.open(root)
	dir.list_dir_begin()

	var fileName := dir.get_next()
	while fileName != "":
		if fileName.ends_with(".tres"):
			var attack := ResourceLoader.load(root + "/" + fileName)
			var button := Button.new()
			button.text = attack.name
			%AttackSelector.add_child(button)
			button.owner = get_tree().edited_scene_root
			button.name = attack.name
			button.pressed.connect(_add_attack.bind(attack), CONNECT_PERSIST)


		elif dir.current_is_dir():
			_traverse_attacks(root + "/" + fileName)

		fileName = dir.get_next()


func _collect_monsters() -> void: 
	for child in %MonsterScroller.get_children(): %MonsterScroller.remove_child(child)
	for monsters: Array in UIManager.beastiary_menu.monsters:
		for monster: BattleActor in monsters:
			var button := Button.new()
			button.text = monster.name
			%MonsterScroller.add_child(button)
			button.name = monster.name
			button.pressed.connect(_add_monster.bind(monster), CONNECT_PERSIST)
			button.owner = get_tree().edited_scene_root


func _add_attack(attack: Attack, uiOnly:=false) -> void:
	if not uiOnly:
		active_actor.attacks.append(attack)

	var item := ListItem.new(attack.name)
	%AttackScroller.add_child(item)
	item.pressed.connect(func() -> void:
		var index := active_actor.attacks.find(attack)
		active_actor.attacks.remove_at(index)
		item.queue_free()
	)


func _add_monster(actor: BattleActor) -> void:
	for child in %AttackScroller.get_children(): %AttackScroller.remove_child(child)

	active_actor = actor.duplicate(true)

	for attack: Attack in actor.attacks:
		_add_attack(attack, true)

	%Name.text = actor.name
	%Level.value = actor.level

	%HpSpinBox.value = actor.stat_manager.hp
	%MASpinBox.value = actor.stat_manager.melee_attack
	%MDSpinBox.value = actor.stat_manager.melee_defense
	%RASpinBox.value = actor.stat_manager.ranged_attack
	%RDSpinBox.value = actor.stat_manager.ranged_defense
	%SpeedSpinBox.value = actor.stat_manager.speed
	

func _on_stat_changed(value: float, stat: int) -> void:
	if active_actor == null: return
	match stat:
		0: active_actor.stat_manager.hp = value
		1: active_actor.stat_manager._base_speed = value
		2: active_actor.stat_manager._base_melee_attack = value
		3: active_actor.stat_manager._base_melee_defense = value
		4: active_actor.stat_manager._base_ranged_attack = value
		5: active_actor.stat_manager._base_ranged_defense = value


func _on_new_battle_actor_button_pressed() -> void:
	_add_monster(BattleActor.new())


func _on_add_opponent_button_pressed() -> void:
	opponents.append(active_actor)
	var item := ListItem.new(active_actor.name)
	var actor := active_actor
	item.pressed.connect(func() -> void:
		var index := opponents.find(actor)
		opponents.remove_at(index)
		item.queue_free()
	)
	%OpponentScroller.add_child(item)
	_add_monster(BattleActor.new())


func _on_add_player_button_pressed() -> void:
	players.append(active_actor)
	var item := ListItem.new(active_actor.name)
	var actor := active_actor
	item.pressed.connect(func() -> void:
		var index := players.find(actor)
		players.remove_at(index)
		item.queue_free()
	)
	%PlayerScroller.add_child(item)
	_add_monster(BattleActor.new())


func _on_start_button_pressed() -> void:
	if len(players) == 0 or len(opponents) == 0: 
		print("Either Players and/or Opponents are empty")
		return
	$Setup.hide()
	Battle.start(players, [], opponents, ai)
	await Battle.battle_ended
	$Setup.show()
