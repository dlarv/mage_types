@tool
extends PuzzleBlock
## Maps received signal (on, off, invalid) to output signal.

@export var lock: PuzzleBlock

@export_enum("on", "off", "invalid") 
var map_on_to := "on"
@export_enum("on", "off", "invalid") 
var map_off_to := "off"
@export_enum("on", "off", "invalid") 
var map_invalid_off_to := "invalid"

func _ready() -> void:
	super._ready()
	if lock == null: return
	lock.on.connect(_on_lock_on)
	lock.off.connect(_on_lock_off)
	lock.invalid_off.connect(_on_lock_invalid_off)


func _on_lock_on(block: PuzzleBlock) -> void: 
	_map(map_on_to)


func _on_lock_off(block: PuzzleBlock) -> void: 
	_map(map_off_to)


func _on_lock_invalid_off(block: PuzzleBlock) -> void: 
	_map(map_invalid_off_to)


func _map(val: String) -> void:
	match val:
		"on":
			on.emit(self)
		"off":
			off.emit(self)
		"invalid",_:
			invalid_off.emit(self)
