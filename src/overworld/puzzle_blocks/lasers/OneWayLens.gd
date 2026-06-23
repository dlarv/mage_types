@tool
extends PuzzleBlock

var _prev_val := -1
var _is_emitting := false
var _material_2: BaseMaterial3D

func _ready() -> void:
	_material_2 = StandardMaterial3D.new()
	super._ready()
	$SubEmitter.stop()


func _on_sub_receiver_laser_received(laser:Laser, point:Vector3) -> void:
	if in_stasis: return
	_is_emitting = true
	$SubEmitter.global_position.y = point.y

	var e := ElementManager.get_matchup(element, laser.element)

	if laser.rand_val != _prev_val: 
		_prev_val = laser.rand_val
		create_log(self, e)

	if in_stasis or e == null or e.is_blank():
		e = laser.element

	$SubEmitter.laser.rand_val = laser.rand_val
	$SubEmitter.set_element(e)
	$SubEmitter.start()


#override
func set_stasis(val:Variant=null) -> void:
	super.set_stasis(val)
	$SubEmitter.pause(in_stasis)


func flicker_collider() -> void:
	var val := collision_layer
	set_collision_layer_value(3, false)
	await get_tree().create_timer(0.01).timeout
	set_collision_layer_value(3, true)



func create_log(body: MagiClay, e: ElementalType) -> void:
	if in_stasis:
		MyLogger.append_puzzle_log("OneWayLens(%s) in stasis collided with laser of Element(%s)."
			% [puzzle_name, body.element])
	elif e == null or e.is_blank():
		MyLogger.append_puzzle_log("OneWayLens(%s) of Element(%s) collided with laser of Element(%s)."
			% [puzzle_name, element, body.element])
	else:
		MyLogger.append_puzzle_log("OneWayLens(%s) of Element(%s) transmuted laser of Element(%s) into Element(%s)." 
			% [puzzle_name, element, body.element, e])


func _on_laser_dropped() -> void:
	_is_emitting = false
	$SubEmitter.stop()
	var e: String = $SubEmitter.laser.element.name if $SubEmitter != null else "null"
	MyLogger.append_puzzle_log("OneWayLens(%s) stopped emitting laser of Element(%s)."
			% [puzzle_name, e])
