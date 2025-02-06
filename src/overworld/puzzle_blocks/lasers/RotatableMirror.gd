@tool
extends PuzzleBlock

func _ready() -> void:
	super._ready()
	position = position.snapped(Vector3(1, 1, 1))
	$Mirror.set_element(element)

func _enter_tree() -> void:
	super._enter_tree()
	$Mirror._original_element = element

func _on_grabbable_grabbed(obj:Node3D, player:Node3D) -> void:
	if not $Mirror._active_receiver: 
		rotation_degrees.y += 90
		return
	var val = $Mirror._active_receiver.collision_layer
	$Mirror._active_receiver.collision_layer = 1
	$Mirror._active_emitter.stop()
	await get_tree().create_timer(0.01).timeout
	rotation_degrees.y += 90
	$Mirror._active_receiver.collision_layer = val
	$Mirror._active_emitter.start()

func _get_mesh() -> MeshInstance3D:
	return $Mirror/MeshInstance3D

# Override
func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if super.set_element(e, randVal, force):
		$Mirror.set_element(e, randVal, force)
		$Mirror._flicker_collider()
		return true
	return false

# Override
func set_stasis() -> void:
	super.set_stasis()
	$Mirror.in_stasis = in_stasis
	$Mirror._flicker_collider()
