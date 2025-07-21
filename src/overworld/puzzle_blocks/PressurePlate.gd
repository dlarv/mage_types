@tool
extends PuzzleBlock

@export var can_player_trigger: bool
@export var on_color := Color.GREEN
@export var off_color := Color.DARK_GRAY
@export var invalid_color := Color.RED

var _on_mat: StandardMaterial3D
var _off_mat: StandardMaterial3D
var _invalid_mat: StandardMaterial3D
var _pressed := false

func _ready() -> void:
	super._ready()
	_on_mat = StandardMaterial3D.new()
	_on_mat.albedo_color = on_color
	_off_mat = StandardMaterial3D.new()
	_off_mat.albedo_color = off_color
	_invalid_mat = StandardMaterial3D.new()
	_invalid_mat.albedo_color = invalid_color

	$Base_MeshInstance3D.set_surface_override_material(0, _off_mat)


func _on_body_entered(body: Node3D) -> void:
	var bodyName: String
	var bodyElement: String
	if body.is_in_group("player"):
		bodyName = "Player"
		bodyElement = "n/a"
	elif not body is MagiClay:
		return
	else:
		bodyName = body.puzzle_name
		bodyElement = str(body.element)

	if _test_for_player(body):
		_try_emit_on()
		Logger.append_puzzle_log("PressurePlate(%s) was activated by player." % [puzzle_name])
	elif body.is_in_group("player"): return
	elif body.in_stasis:
		Logger.append_puzzle_log("PressurePlate(%s) could not be activated by MagiClay(%s), b/c its in stasis." 
				% [puzzle_name, body.puzzle_name])
		off.emit(self)
	elif element.is_blank() or body.element == element:
		Logger.append_puzzle_log("PressurePlate(%s) was activated by MagiClay(%s)." 
				% [puzzle_name, body.puzzle_name])
		_try_emit_on()
	else:
		Logger.append_puzzle_log("PressurePlate(%s) was stepped on, but not activated, by Object(%s). Object is Element(%s), but plate requires Element(%s)." 
				% [puzzle_name, bodyName, bodyElement, element])
		_try_emit_off()
		$Base_MeshInstance3D.set_surface_override_material(0, _invalid_mat)
		invalid_off.emit(self)
		is_on = true


func _on_body_exited(body: Node3D) -> void:
	if not is_on: return
	elif _test_for_player(body): 
		Logger.append_puzzle_log("PressurePlate(%s) was deactivated by player." % puzzle_name)
		_try_emit_off()
	elif body is MagiClay:
		Logger.append_puzzle_log("PressurePlate(%s) was deactivated by MagiClay(%s)." 
				% [puzzle_name, body.puzzle_name])
		_try_emit_off()


func _try_emit_off() -> bool:
	if not super._try_emit_off(): return false
	$Base_MeshInstance3D.set_surface_override_material(0, _off_mat)
	if _pressed:
		$AnimationPlayer.play_backwards("press")
	_pressed = false
	return true


func _try_emit_on() -> bool:
	if not super._try_emit_on(): return false
	$Base_MeshInstance3D.set_surface_override_material(0, _on_mat)
	if not _pressed:
		$AnimationPlayer.play("press")
	_pressed = true
	return true


func _test_for_player(body: Node3D) -> bool:
	return can_player_trigger and element == ElementManager.Blank and body.is_in_group("player")
