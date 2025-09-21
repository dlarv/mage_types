@tool
extends MagiClay
class_name WildEnemyActor

@export var use_placeholder_mesh := true
@export var team: Array[BattleActor]
@export var ai: OpponentController

var state_machine: _EnemyBehavior
var mesh: MeshInstance3D

var _on_cooldown := false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	for child in get_children():
		if child is _EnemyBehavior:
			state_machine = child
		elif child is MeshInstance3D:
			mesh = child
	
	if len(team) > 0 and not team[0].element_changed.is_connected(_set_mesh_color):
		team[0].element_changed.connect(_set_mesh_color)
		_set_mesh_color(0, team[0].element1)
		_set_mesh_color(1, team[0].element2)

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
		team.append_array(other.team)


func _set_mesh_color(id: int, color: ElementalType) -> void:
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

