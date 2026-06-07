@tool
extends PuzzleBlock

@export var shutoff_upon_trigger := true
@export var use_laser_input := true

var _prev_val := -1
var _is_emitting := false


func _ready() -> void:
	super._ready()

	if not use_laser_input:
		_start_no_laser()
	else:
		$SubEmitter.stop()
		$SubEmitter2.stop()

	if not $SubEmitter.laser_broken.is_connected(_on_laser_broken):
		$SubEmitter.laser_broken.connect(_on_laser_broken)
	if not $SubEmitter2.laser_broken.is_connected(_on_laser_broken):
		$SubEmitter2.laser_broken.connect(_on_laser_broken)


func _start_no_laser() -> void:
	_is_emitting = true
	$SubEmitter.set_element(element)
	$SubEmitter.start()
	$SubEmitter2.set_element(element)
	$SubEmitter2.start()
	_prev_val = $SubEmitter.laser.rand_val
	$SubEmitter2.laser.rand_val = _prev_val


func _on_laser_received(laser:Laser, point:Vector3) -> void:
	_is_emitting = true

	if laser.rand_val != _prev_val: 
		_prev_val = laser.rand_val
		MyLogger.append_puzzle_log("Bridge(%s) collided with laser of Element(%s)."
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


func reset(resetPosition:=false) -> void:
	super.reset(resetPosition)

	if not use_laser_input:
		_start_no_laser()
	elif _is_emitting:
		$SubEmitter.start()
		$SubEmitter2.start()


func _get_mesh() -> MeshInstance3D:
	return $Model/Bridge


func _on_laser_broken() -> void:
	if shutoff_upon_trigger: 
		MyLogger.append_puzzle_log("Bridge(%s)'s laser was triggered and shutoff." % [puzzle_name])
		$SubEmitter.stop()
		$SubEmitter2.stop()
