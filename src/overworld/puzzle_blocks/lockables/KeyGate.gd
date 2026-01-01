extends StaticBody3D

@export var key_name: StringName

var puzzle_name: String:
	get():
		if get_parent() == null:
			return "%s" % name
		return "%s.%s" % [get_parent().name, name]

var _already_opened := false
var _is_locked := true


func _physics_process(delta: float) -> void:
	# For some reason, collision_layer would oscillate between 0 and 1.
	if not _is_locked:
		self.collision_layer = 0


func _on_interactable_interacted(obj:Node3D) -> void:
	if _already_opened: return

	Logger.append_puzzle_log("KeyGate(%s) is checking for Key(%s)." % [puzzle_name, key_name])
	if Inventory.has_key_item(key_name):
		Logger.append_puzzle_log("KeyGate(%s) was unlocked")
		self.collision_layer = 0
		$AnimationPlayer.play("opening")
		await $AnimationPlayer.animation_finished
		queue_free()
	else:
		Logger.append_puzzle_log("Key(%s) not found, KeyGate(%s) was not unlocked" % [key_name, puzzle_name])
