@tool
extends MagiClay
class_name WildEnemyActor

@export_tool_button("Create Skeleton") 
var create_skeleton := func() -> void:
	var collider1 := CollisionShape3D.new()
	add_child(collider1, true)
	collider1.owner = get_tree().edited_scene_root
	collider1.shape = CapsuleShape3D.new()
	collider1.position.y = 1

	var mesh := MeshInstance3D.new()
	mesh.mesh = CapsuleMesh.new()
	mesh.position.y = 1
	add_child(mesh, true)
	mesh.owner = get_tree().edited_scene_root

	var mat := StandardMaterial3D.new()
	var tex := GradientTexture1D.new()
	tex.gradient = Gradient.new()
	tex.gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	tex.gradient.set_offset(0, 0.5)
	tex.gradient.set_offset(1, 0.0)
	mat.albedo_texture = tex
	mesh.set_surface_override_material(0, mat)

	var area := Area3D.new()
	area.name = "BattleTrigger"
	add_child(area, true)
	area.collision_mask = 32
	area.collision_layer = 0
	area.owner = get_tree().edited_scene_root
	
	# This must be done manually.
	# area.body_entered.connect(_on_battle_trigger_body_entered)

	var collider2 := CollisionShape3D.new()
	area.add_child(collider2, true)
	collider2.owner = get_tree().edited_scene_root
	collider2.shape = CapsuleShape3D.new()
	collider2.position.y = 1

@export var use_placeholder_mesh := true
@export var team: Array[BattleActor]
@export var ai: OpponentController
@export var reward_items: Dictionary[_Item, float] = {}

var state_machine: _EnemyBehavior
var mesh: MeshInstance3D

var _on_cooldown := false

func _ready() -> void:
	if len(team) > 0 and not team[0].element_changed.is_connected(_set_mesh_color):
		team[0].element_changed.connect(_set_mesh_color)
		_set_mesh_color(0, team[0].element1)
		_set_mesh_color(1, team[0].element2)

	for child in get_children():
		if child is _EnemyBehavior:
			state_machine = child
		elif child is MeshInstance3D:
			mesh = child

	if Engine.is_editor_hint(): return
	# Prevent different enemies from sharing resources
	for actor in team:
		actor.resource_local_to_scene = true
		actor.stat_manager.resource_local_to_scene = true


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	self.velocity = state_machine.get_next_position() * delta
	_move_and_slide()


func _move_and_slide() -> void:
	var s: Node3D = self
	s.move_and_slide()


func react(e: ElementalType, randVal:=-2) -> bool:
	if not set_element(e, randVal): return false

	for actor: BattleActor in team:
		var e1 := ElementManager.get_matchup(actor.element2, e)
		if e1:
			actor.set_element(1, e1)

		var e2 := ElementManager.get_matchup(actor.element1, e1)
		if e2:
			actor.set_element(1, e2)

	return true


## other: BattleActor | WildEnemyActor
func add_ally(other: Variant) -> void:
	if other is BattleActor:
		team.append(other)
	elif other is WildEnemyActor:
		team.append_array(other.team.map(func(x: BattleActor) -> BattleActor: return x.duplicate()))
		ai.reward_xp += other.ai.reward_xp

		for item: _Item in other.reward_items:
			if reward_items.has(item):
				reward_items[item] += other.reward_items[item]


func select_rewards() -> void:
	ai.reward_xp *= team[0].level
	ai.reward_items = []
	for item in reward_items:
		var rand := randf()
		if rand <= reward_items[item]:
			var slot := ItemSlot.new(item)
			ai.reward_items.append(slot)


func set_level(level: int, id:=0) -> void:
	var diff := level - team[id].level
	if diff == 0: return
	team[id].level = level

	const S := StatManager.Stats
	for stat: S in [S.MELEE_ATTACK, S.RANGED_ATTACK, S.MELEE_DEFENSE, S.RANGED_DEFENSE, S.SPEED, S.HP]:
		# Everytime player levels up, they receive +18 BST.
		# This attempts to mimic that somewhat.
		var base := randf_range(0, PlayerStatManager.MAX_STAT_POINTS + 1)
		team[id].stat_manager.raise_base_stat(stat, base * diff)


func _set_mesh_color(id: int, color: ElementalType) -> void:
	if not mesh:
		var instances := find_children("", "MeshInstance3D", true)
		if len(instances) == 0:
			return
		mesh = instances[0]

	if use_placeholder_mesh:
		var texture: GradientTexture1D = mesh.get_surface_override_material(0).albedo_texture
		texture.gradient.set_color(id, color.main_color)


func _get_mesh() -> MeshInstance3D: return null
func _set_material(val: BaseMaterial3D) -> void: pass 


func _on_battle_trigger_body_entered(body:Node3D) -> void:
	if not _on_cooldown:
		get_tree().call_group("wild_enemies", "_start_battle_cooldown")
		body.call_deferred("start_battle", self)
		queue_free()
