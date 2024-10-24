@tool
@icon("res://addons/NpcIcon.png")
extends Node3D
class_name Npc


@export var actor_name: String:
	set(value):
		actor_name = value
		find_actors()
		if story_actor != null:
			story_actor.actor_name = value
		elif enemy_actor != null and len(enemy_actor.team) > 0:
			enemy_actor.team[0].name = value
@export var ai: OpponentController
@export var _mesh_instance: MeshInstance3D
@export 
var tint := Color.WHITE: 
	set(value):
		tint = value
		_next_pass.albedo_color = tint
@export 
var use_tint := false:
	set(value):
		use_tint = value

		# Return material to original state.
		_mesh_instance.set_surface_override_material(0, null)
		if not value: return

		# Create new unique base texture.
		var material := _mesh_instance.get_active_material(0).duplicate(true)
		_mesh_instance.set_surface_override_material(0, material)
		_next_pass.blend_mode = BaseMaterial3D.BLEND_MODE_MUL
		material.next_pass = _next_pass
@export var size := 1.0:
	set(value):
		size = value
		var s = Vector3(size, size, size)
		var h = (size - 1) * .5 + .25

		if _mesh_instance != null: 
			_mesh_instance.scale = s
			_mesh_instance.position.y = h
		find_actors()
		resize_actors()
var story_actor: StoryActor
var enemy_actor: EnemyActor

var _next_pass := StandardMaterial3D.new()

func _ready():
	find_actors()
	resize_actors()

func find_actors() -> void:
	if story_actor != null or enemy_actor != null: return

	for child in get_children(true):
		if child is AggressiveStoryActor: story_actor = child
		elif child is EnemyActor: enemy_actor = child
	
	if Engine.is_editor_hint(): return
	if story_actor != null and enemy_actor != null and not enemy_actor.ai.battle_ended.is_connected(story_actor._on_battle_ended):
		enemy_actor.ai.battle_ended.connect(story_actor._on_battle_ended)

func resize_actors() -> void:
	var s = Vector3(size, size, size)
	var h = (size - 1) * .5 + .25
	if story_actor != null:
		story_actor.set_size(s, h)
	if enemy_actor != null:
		enemy_actor.set_size(s, h)
