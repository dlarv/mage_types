@tool
extends PuzzleBlock

var laser: Laser

# The way I built this, the start() and stop() functions cannot alter super.is_on, 
# or else there will be a recursive bomb.
var _is_on: bool

func _ready() -> void:
	if Engine.is_editor_hint(): return
	super._ready()

	laser = $SubEmitter.laser
	laser.emitter_puzzle_name = puzzle_name
	$SubEmitter.set_element(element)

	if is_on:
		start()
	else:
		stop()

func start(val: Variant=null) -> void: 
	if Engine.is_editor_hint(): return
	super.start(val)
	_is_on = true
	$SubEmitter.start()
	MyLogger.append_puzzle_log("Emitter(%s) started. Element(%s). Hash(%d)" % [puzzle_name, element, laser.rand_val])

func stop(val: Variant=null) -> void: 
	if Engine.is_editor_hint(): return
	super.stop(val)
	_is_on = false
	$SubEmitter.stop()
	MyLogger.append_puzzle_log("Emitter(%s) stopped." % [puzzle_name])

# Override
func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if not super.set_element(e, randVal, force): return false
	await $SubEmitter.set_element(e)
	return true

func set_stasis(val:Variant=null) -> void:
	await super.set_stasis(val)
	if in_stasis:
		stop()
	else:
		start()
