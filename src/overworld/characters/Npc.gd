@tool
extends MagiClay

signal battle_ended(state: Battle.EndState)

@export var auto_trigger := false
@export var disabled := false:
	set(val):
		disabled = val
		$Interactable.disabled = val

var story_actor: StoryActor = null
var vendor_actor: VendorActor = null
var enemy_actor: EnemyActor = null
var animation_actor: AnimationActor = null
# Player or PhysicsPlayer
var _player: Variant

var _on_cooldown := false

func _enter_tree():
	super._enter_tree()

	for child in get_children():
		if child is VendorActor: 
			vendor_actor = child
		elif child is StoryActor:
			story_actor = child
		elif child is EnemyActor:
			enemy_actor = child
			enemy_actor.battle_ended.connect(func(state): battle_ended.emit(state))
		elif child is AnimationActor:
			animation_actor = child

func _ready() -> void:
	_player = get_tree().get_nodes_in_group("player")
	if len(_player) > 0:
		_player = _player[0]

func _on_body_entered(body:Node3D) -> void:
	if not body.is_in_group("player"): return

	if animation_actor and auto_trigger:
		animation_actor.play_animation(body)
		$Interactable.set_disabled(true)
		set_deferred("monitoring", false)
	elif story_actor and auto_trigger:
		body.call_deferred("start_dialog", self)
		$Interactable.set_disabled(true)
		set_deferred("monitoring", false)
	elif story_actor or vendor_actor: 
		pass
	elif enemy_actor and not _on_cooldown:
		get_tree().call_group("wild_enemies", "_start_battle_cooldown")
		body.call_deferred("start_battle", self)
			

## Called by OverworldConnector is this character is part of the "wild_enemies" group.
func _end_battle_cooldown() -> void:
	_on_cooldown = false 


func _start_battle_cooldown() -> void:
	_on_cooldown = true


func get_next_dialog_id() -> String:
	if not story_actor: return ""
	return story_actor.get_next_dialog_id()


func serialize() -> Dictionary:
	return {
		"path": get_path(),
		"monitoring": self.monitoring,
		"dialog_id": story_actor.current_id if story_actor else -2,
		"position": global_position,
	}


func deserialize(data: Dictionary) -> void:
	self.monitoring = data["monitoring"]
	if data["dialog_id"] != -2:
		story_actor.current_id = data["dialog_id"]
	global_position = data["position"]


func _on_interactable_interacted(obj:Node3D) -> void:
	if not _player: return
	if story_actor != null:
		_player.call_deferred("start_dialog", self)
	else:
		_player.call_deferred("open_shop", self)

