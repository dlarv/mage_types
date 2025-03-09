extends Node3D

signal element_selected(element: ElementalType)

@export var elements := {
	# "Blank": false,
	"Blue": true,
	"Purple": true,
	"Magenta": true,
	"Red": true,
	"Orange": true,
	"Yellow": true,
	"Green": true,
	"Cyan": true,
}
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blue":
	get:
		return _element
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element: ElementalType = ElementManager.Blue:
	set(value):
		if value == null:
			value = ElementManager.Blank
		element = value 

func _ready() -> void:
	for child in %GridContainer.get_children():
		child.disabled = not elements[child.name]

	$CanvasLayer.hide()
	_rotate_wheel(element)

func _on_element_button_pressed(element: ElementalType) -> void:
	self.element = element


func _rotate_wheel(element: ElementalType) -> void:
	var tween = get_tree().create_tween()
	var degrees: float
	match element.name:
		"Blue": degrees = 0
		"Purple": degrees = 45
		"Magenta": degrees = 45 * 2
		"Red": degrees = 45 * 3
		"Orange": degrees = 45 * 4
		"Yellow": degrees = 45 * 5
		"Green": degrees = 45 * 6
		"Cyan": degrees = 45 * 7
	
	tween.tween_property($catalyst_device/Plane, "rotation_degrees", Vector3(0, 0, degrees), 1) 


func _on_grabbable_grabbed(obj:Node3D, player:Node3D) -> void:
	$CanvasLayer.show()
	if not %Close_Button.pressed.is_connected(_on_close_button_pressed):
		%Close_Button.pressed.connect(_on_close_button_pressed.bind(player))
	player.process_mode = Node.PROCESS_MODE_DISABLED
	UIManager.hud.hide()


func _on_close_button_pressed(player: Node3D) -> void:
	$CanvasLayer.hide()
	player.process_mode = Node.PROCESS_MODE_INHERIT
	UIManager.hud.show()
	if element:
		_rotate_wheel(element)
		element_selected.emit(element)
