@tool
extends Node3D

const BASE := 10

## Which nib is currently lit up.
@export
var incr: bool:
	set(val):
		increment()
@export
var decr: bool:
	set(val):
		decrement()

@export var clear: bool:
	set(val):
		unlight_all()
		$Label3D.text = "1"
		_curr_index = 0
		_active_material = _positive_material

var _curr_amount := 100
var _curr_index := 0
var _unlit_material: BaseMaterial3D
var _positive_material: BaseMaterial3D
var _negative_material: BaseMaterial3D
var _active_material: BaseMaterial3D

func _ready() -> void:
	_unlit_material = StandardMaterial3D.new()
	_unlit_material.emission_enabled = true
	_unlit_material.emission = Color.BLACK
	_unlit_material.albedo_color = Color.WHITE

	_positive_material = StandardMaterial3D.new()
	_positive_material.emission_enabled = true
	_positive_material.emission = Color.GREEN
	_positive_material.albedo_color = Color.GREEN

	_negative_material = StandardMaterial3D.new()
	_negative_material.emission_enabled = true
	_negative_material.emission = Color.RED
	_negative_material.albedo_color = Color.RED

	unlight_all()
	_active_material = _positive_material


## Updates in increments of 10%.
func increment() -> void:
	_curr_index += 1
	if _get_index() == 0:
		if _curr_index == 0:
			_active_material = _positive_material
			unlight_all()
		elif _curr_index > 0:
			unlight_all()
		else:
			light_all()

		# Update counter
		var num := int($Label3D.text) + 1
		$Label3D.text = str(num)
	elif _curr_index < 0:
		$Medallion.set_surface_override_material(_get_index(), _unlit_material)
	else:
		$Medallion.set_surface_override_material(_get_index(), _active_material)


func decrement() -> void:
	print(_curr_index)
	if _get_index() == 0:
		if _curr_index == 0:
			_active_material = _negative_material
			light_all()
		elif _curr_index > 0:
			light_all()
		else:
			unlight_all()

		# Update counter
		var num := int($Label3D.text) - 1
		$Label3D.text = str(num)
	elif _curr_index >= -BASE:
		$Medallion.set_surface_override_material(_get_index(), _unlit_material)
	else:
		$Medallion.set_surface_override_material(_get_index(), _active_material)
	_curr_index -= 1


func _get_index() -> int:
	return abs(_curr_index % BASE)


func light_all() -> void:
	$Medallion.set_surface_override_material(1, _active_material)
	$Medallion.set_surface_override_material(2, _active_material)
	$Medallion.set_surface_override_material(3, _active_material)
	$Medallion.set_surface_override_material(4, _active_material)
	$Medallion.set_surface_override_material(5, _active_material)
	$Medallion.set_surface_override_material(6, _active_material)
	$Medallion.set_surface_override_material(7, _active_material)
	$Medallion.set_surface_override_material(8, _active_material)
	$Medallion.set_surface_override_material(9, _active_material)


func unlight_all() -> void:
	$Medallion.set_surface_override_material(1, _unlit_material)
	$Medallion.set_surface_override_material(2, _unlit_material)
	$Medallion.set_surface_override_material(3, _unlit_material)
	$Medallion.set_surface_override_material(4, _unlit_material)
	$Medallion.set_surface_override_material(5, _unlit_material)
	$Medallion.set_surface_override_material(6, _unlit_material)
	$Medallion.set_surface_override_material(7, _unlit_material)
	$Medallion.set_surface_override_material(8, _unlit_material)
	$Medallion.set_surface_override_material(9, _unlit_material)


func light_n(num: int, mat: StandardMaterial3D) -> void:
	for i in range(1, 10):
		if num >= i:
			$Medallion.set_surface_override_material(i, mat)
		else:
			$Medallion.set_surface_override_material(i, _unlit_material)


func update(amount: float) -> void:
	amount *= 100
	var hundreds := int(amount / 100.0)
	var tens := int(float(int(amount) % 100) / 10.0 * 10)
	
	if amount >= 0:
		$Label3D.text = str(hundreds)
		light_n(round(tens / 10.0), _positive_material)
	else:
		$Label3D.text = str(hundreds)
		light_n(round(-tens / 10.0), _negative_material)
