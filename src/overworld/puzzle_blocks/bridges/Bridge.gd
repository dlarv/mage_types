@tool
extends PuzzleBlock

@export var shutoff_upon_trigger := true

var _prev_val := -1
var _is_emitting := false


func _enter_tree() -> void:
	$SubEmitter.stop()
	$SubEmitter2.stop()

	if not $SubEmitter.laser_broken.is_connected(_on_laser_broken):
		$SubEmitter.laser_broken.connect(_on_laser_broken)
	if not $SubEmitter2.laser_broken.is_connected(_on_laser_broken):
		$SubEmitter2.laser_broken.connect(_on_laser_broken)


func _on_laser_received(laser:Laser, point:Vector3) -> void:
	_is_emitting = true

	if laser.rand_val != _prev_val: 
		_prev_val = laser.rand_val
		Logger.append_puzzle_log("Bridge(%s) collided with laser of Element(%s)."
			% [puzzle_name, laser.element])

	if not set_element(laser.element): return

	$SubEmitter.laser.rand_val = laser.rand_val
	$SubEmitter.set_element(laser.element)
	$SubEmitter.start()
	$SubEmitter2.laser.rand_val = laser.rand_val
	$SubEmitter2.set_element(laser.element)
	$SubEmitter2.start()


func _on_laser_dropped() -> void:
	_is_emitting = false
	element = ElementManager.Blank
	_try_set_color()
	$SubEmitter.stop()
	$SubEmitter2.stop()


func reset() -> void:
	super.reset()
	if _is_emitting:
		$SubEmitter.start()
		$SubEmitter2.start()


func _get_mesh() -> MeshInstance3D:
	return $Model/Bridge


func _on_laser_broken() -> void:
	if shutoff_upon_trigger: 
		Logger.append_puzzle_log("Bridge(%s)'s laser was triggered and shutoff." % [puzzle_name])
		$SubEmitter.stop()
		$SubEmitter2.stop()


