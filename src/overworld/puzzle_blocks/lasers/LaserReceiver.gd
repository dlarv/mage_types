@tool
extends PuzzleBlock

@export var valid_color := Color.GREEN
@export var invalid_color := Color.RED
@export var off_color := Color.GRAY
@export var delay := 15.0

var _valid_mat: BaseMaterial3D
var _invalid_mat: BaseMaterial3D
var _off_mat: BaseMaterial3D
var _delay := 0.0
var _prev_val := -2

func _ready() -> void:
	_valid_mat = StandardMaterial3D.new()
	_valid_mat.albedo_color = valid_color
	_invalid_mat = StandardMaterial3D.new()
	_invalid_mat.albedo_color = invalid_color
	_off_mat = StandardMaterial3D.new()
	_off_mat.albedo_color = off_color

	$Indicator.set_surface_override_material(0, _off_mat)


func _process(delta: float) -> void:
	_delay += delta
	if _delay >= delay:
		$Indicator.set_surface_override_material(0, _off_mat)


func _on_body_entered(body:Node3D) -> void:
	if not "element" in body: return
	var msg: String

	if body.get_collision_layer_value(5): 
		if element.is_blank() or body.element == element:
			_try_emit_on()
			$Indicator.set_surface_override_material(0, _valid_mat)
			msg = "LaserReceiver(%s) hit by valid laser." % [puzzle_name]
		else:
			$Indicator.set_surface_override_material(0, _invalid_mat)
			msg = "LaserReceiver(%s) hit by invalid laser. Laser was Element(%s), but requires Element(%s)." \
					% [puzzle_name, body.element.name, element.name]
					
		_delay = 0
		if _prev_val != body.rand_val:
			Logger.append_log(Logger.LogType.PUZZLE, msg)
		else:
			_prev_val = body.rand_val
		body.queue_free()
