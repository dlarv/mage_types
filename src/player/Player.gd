extends CharacterBody3D
class_name Player 

signal actor_changed(actor: BattleActor)
signal team_changed(team: Array)
signal battle_started(allies, enemies)
signal dialog_started(dialog_id, npc)
signal cutscene_started(player: AnimationPlayer, id: String)

@export var battle_actor: BattleActor:
	set(val):
		battle_actor = val
		# When BattleActor is changed via AnimationPlayer, the player screen will not update.
		if not Engine.is_editor_hint():
			actor_changed.emit(val)
@export var team: Array[BattleActor]:
	set(val):
		team = val
		if not Engine.is_editor_hint():
			team_changed.emit(team)
## Used by AnimationPlayers to add BattleActors to player's team.
@export var add_team_member: BattleActor:
	set(val):
		if Engine.is_editor_hint():
			add_team_member = val
		else:
			team.append(val)
			team_changed.emit(team)

@export var model: Node3D
@export var anim_player: AnimationPlayer


var player_name: 
	get:
		return battle_actor.name
	set(val):
		battle_actor.name = player_name

var active_chunk: Chunk = null
var _golem: Golem = null

func _ready() -> void:
	if not battle_actor in team:
		team.insert(0, battle_actor)
	
	player_name = Settings.player_name
	Settings.player_name_changed.connect(func(name):
		player_name = name)


func start_battle(npc: Variant) -> void:
	battle_started.emit(team, npc.enemy_actor)


func open_shop(npc: Variant) -> void:
	dialog_started.emit("VENDOR_MAIN", npc)


func start_dialog(npc: Variant) -> void:
	var id = npc.get_next_dialog_id()
	if len(id) == 0: return
	dialog_started.emit(id, npc)


func create_golem(golem: Golem) -> void:
	if _golem:
		_golem.kill()
	_golem = golem
	active_chunk.add_golem(golem)


func play_cutscene(player: AnimationPlayer, id: String) -> void:
	cutscene_started.emit(player, id)


func look_towards(point: Vector3, yOnly := true) -> void:
	if yOnly:
		point.y = model.global_position.y
	model.look_at(point)
	# Model is facing the opposite way, so correct.
	model.global_rotation_degrees.y += 180


func serialize() -> Dictionary:
	var teamData := []
	for t in team:
		teamData.append(t.serialize())
	return {
		"path": get_path(),
		"battle_actor": battle_actor.serialize(),
		"team": teamData,
		"position": global_position,
		"rotation": global_rotation,
		"model_rotation": model.global_rotation,
	}


func deserialize(data: Dictionary):
	if "position" in data:
		global_position = data["position"]
	if "rotation" in data:
		global_rotation = data["rotation"]
	if "model_rotation" in data:
		model.global_rotation = data["model_rotation"]
	if "battle_actor" in data:
		battle_actor.deserialize(data["battle_actor"])
	# if "team" in data:
	# 	team = []
	# 	for t in data["team"]:
	# 		team.append(BattleActor.new())


