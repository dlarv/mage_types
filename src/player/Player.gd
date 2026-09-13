extends CharacterBody3D

enum PartyMember { PARTNER }

signal actor_changed(actor: BattleActor)
signal team_changed(team: Array[BattleActor])
signal battle_started(allies: Array[BattleActor], enemies: Variant)
signal dialog_started(dialog_id: String, npc: Variant)
signal cutscene_started(player: AnimationPlayer, id: String)

@export var model: Node3D
@export var anim_player: AnimationPlayer

@export_category("Party")
@export var battle_actor: BattleActor:
	set(val):
		battle_actor = val
		# When BattleActor is changed via AnimationPlayer, the player screen will not update.
		if not Engine.is_editor_hint():
			actor_changed.emit(val)
## Used by AnimationPlayers to add BattleActors to player's team.
@export var add_team_member: BattleActor:
	set(val):
		if Engine.is_editor_hint():
			add_team_member = val
		else:
			team.append(val)
			team_changed.emit(team)

@export var _playable_characters: Dictionary[PartyMember, BattleActor] = {}
@export var _active_party: Array[PartyMember]:
	set(val):
		_active_party = val
		if Engine.is_editor_hint(): return
		team_changed.emit(team)
var team: Array[BattleActor] = []

var player_name: String: 
	get:
		return battle_actor.name
	set(val):
		battle_actor.name = player_name

var active_chunk: Chunk = null
var _golem: Golem = null

func _ready() -> void:
	# player_name = Settings.player_name
	# Settings.player_name_changed.connect(func(name: String) -> void:
	# 	player_name = name
	# )

	if ProjectSettings.get_setting("custom/general/play_test_mode"):
		var spawnPoint: Node3D = get_tree().get_current_scene().get_node("%PlayTestModeSpawnPoint")
		if spawnPoint:
			global_position = spawnPoint.global_position
	
	team = [ battle_actor ]
	for actor in _active_party:
		team.append(_playable_characters[actor])
	team_changed.emit(team)

	# battle_actor.stat_manager.current_hp = battle_actor.stat_manager.hp


func start_battle(npc: Variant) -> void:
	battle_started.emit(team, npc)


func open_shop(npc: Variant) -> void:
	dialog_started.emit("VENDOR_MAIN", npc)


func start_dialog(npc: Variant) -> void:
	var id: String = npc.get_next_dialog_id()
	if len(id) == 0: return
	dialog_started.emit(id, npc)


func create_golem(golem: Golem) -> void:
	active_chunk.add_golem(golem)
	golem.golem_name = "%s.%s" % [active_chunk.name, name]
	golem.parent_chunk = active_chunk

	if _golem:
		MyLogger.append_golem_log("Previous Golem(%s) killed b/c new Golem(%s) created." 
				% [_golem.golem_name, golem.golem_name])
		_golem.kill()

	_golem = golem

	MyLogger.append_golem_log("Golem(%s) of Element(%s) with Instructions(%s) created." 
			% [golem.golem_name, golem.element, golem.instructions_to_string()])

	golem.start()
	#await golem.execute()
	#golem.kill()
	#MyLogger.append_golem_log("Golem(%s) expired." % golem.golem_name)


func play_cutscene(player: AnimationPlayer, id: String) -> void:
	cutscene_started.emit(player, id)


func look_towards(point: Vector3, yOnly := true) -> void:
	if yOnly:
		point.y = model.global_position.y
	if point == model.global_position:
		return
	model.look_at(point)
	# Model is facing the opposite way, so correct.
	model.global_rotation_degrees.y += 180


func add_ally(allyName: String) -> void:
	var id := PartyMember.keys().find(allyName.to_upper())
	if id == -1:
		push_warning("Could not find partymember with name '%s'" % allyName)
		return

	MyLogger.append_story_log("%s joined the player's party!" % allyName)
	_active_party.append(id as PartyMember)

	team = [ battle_actor ]
	for actor in _active_party:
		team.append(_playable_characters[actor])

	team_changed.emit(team)


func remove_ally(allyName: String) -> void:
	var id := PartyMember.keys().find(allyName.to_upper())
	if id == -1:
		push_warning("Could not find partymember with name '%s'" % allyName)
		return

	var index := _active_party.find(id as PartyMember)
	if id == -1:
		push_warning("Tried to remove partymember '%s' from active party, but they are not active." % allyName)
		return

	MyLogger.append_story_log("%s left the player's party!" % allyName)
	_active_party.remove_at(index)

	team = [ battle_actor ]
	for actor in _active_party:
		team.append(_playable_characters[actor])

	team_changed.emit(team)


func serialize() -> Dictionary:
	var teamData := {}
	for key in _playable_characters:
		teamData[key] = _playable_characters[key].serialize()

	return {
		"path": get_path(),
		"battle_actor": battle_actor.serialize(),
		"pcs": teamData,
		"position": global_position,
		"rotation": global_rotation,
		"model_rotation": model.global_rotation,
		"active_team": _active_party,
	}


func deserialize(data: Dictionary) -> void:
	if "position" in data:
		global_position = data["position"]
	if "rotation" in data:
		global_rotation = data["rotation"]
	if "model_rotation" in data:
		model.global_rotation = data["model_rotation"]
	if "battle_actor" in data:
		battle_actor.deserialize(data["battle_actor"])

	# team_changed signal will send, but team array will be empty.
	# we'll do it manually at end of func.
	if "active_team" in data: 
		_active_party = data["active_team"]
	team.resize(len(_active_party))

	if not "pcs" in data: return
	for key: PartyMember in data["pcs"]:
		_playable_characters[key].deserialize(data["pcs"][key])

		var index := _active_party.find(key)
		if index != -1:
			team[index] = _playable_characters[key]

	team_changed.emit(team)
	actor_changed.emit(battle_actor)


