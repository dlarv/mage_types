@tool
extends MagiClay

## If true, MagiClay will transmute as soon as it touches the platform.
## Otherwise, it will only transmute when set_element() is called,
## e.g. when this platform's CatalystDevice is activated.
@export var trigger_on_contact := false
var _clay: MagiClay

# Override
func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if not super.set_element(e, randVal, force): return false
	if _clay:
		_clay.set_element(e)
	return true

func _on_body_exited(body:Node3D) -> void:
	if not body is MagiClay: return
	_clay = null


func _on_body_entered(body:Node3D) -> void:
	if not body is MagiClay: return
	_clay = body
	if trigger_on_contact:
		_clay.set_element(element)

# Effects of _flicker_collider are done manually during set_element.
# Otherwise, _on_body_exited clears the stored _clay and nothing happens.
func flicker_collider() -> void:
	return

