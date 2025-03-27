@tool
extends PuzzleBlock

@export var valid_color := Color.GREEN
@export var invalid_color := Color.RED
@export var off_color := Color.GRAY
@export var delay := 15.0

var _valid_mat: BaseMaterial3D
var _invalid_mat: BaseMaterial3D
var _off_mat: BaseMaterial3D
var _prev_val := -2

func _ready() -> void:
	super._ready()
	_valid_mat = StandardMaterial3D.new()
	_valid_mat.albedo_color = valid_color
	_invalid_mat = StandardMaterial3D.new()
	_invalid_mat.albedo_color = invalid_color
	_off_mat = StandardMaterial3D.new()
	_off_mat.albedo_color = off_color

	$Indicator.set_surface_override_material(0, _off_mat)


func _on_sub_receiver_laser_received(laser:Laser, point:Vector3) -> void:
	var msg: String

	if _prev_val != laser.rand_val:
		_prev_val = laser.rand_val
		Logger.append_puzzle_log( msg)

	if element.is_blank() or laser.element == element:
		_try_emit_on()
		$Indicator.set_surface_override_material(0, _valid_mat)
		on.emit(self)
		msg = "LaserReceiver(%s) hit by valid laser." % [puzzle_name]
	else:
		$Indicator.set_surface_override_material(0, _invalid_mat)
		msg = "LaserReceiver(%s) hit by invalid laser. Laser was Element(%s), but requires Element(%s)." \
				% [puzzle_name, laser.element.name, element.name]
		off.emit(self)



func _on_sub_receiver_laser_dropped() -> void:
	$Indicator.set_surface_override_material(0, _off_mat)
	off.emit(self)

