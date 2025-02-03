@tool
extends PuzzleBlock

@export var Laser: PackedScene
@export var laser_speed := 10.0
@export var laser_lifetime := 8.0

var _hash := -1

# The way I built this, the start() and stop() functions cannot alter super.is_on, 
# or else there will be a recursive bomb.
var _is_on: bool

func _ready() -> void:
	if Engine.is_editor_hint(): return
	super._ready()

	if is_on:
		start()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _is_on and $Timer.is_stopped() and not in_stasis:
		var laser := Laser.instantiate()
		laser.setup($Marker3D.position, transform.basis.y, element, _hash)
		add_child(laser)
		$Timer.start()

func start(val: Variant=null) -> void: 
	super.start(val)
	_is_on = true
	_hash = Time.get_ticks_usec()
	Logger.append_log(Logger.LogType.PUZZLE, 
			"Emitter(%s) started. Element(%s). Hash(%d)" % [puzzle_name, element.name, _hash])

func stop(val: Variant=null) -> void: 
	super.stop(val)
	_is_on = false
	Logger.append_log(Logger.LogType.PUZZLE, 
			"Emitter(%s) stopped." % [puzzle_name])
