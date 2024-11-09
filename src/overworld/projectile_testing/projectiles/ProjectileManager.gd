@tool
extends Node3D

@export var ProjectilePrefab: PackedScene
@export var GhostProjectile: PackedScene
@export var max_bounces := 3
@export var override_bounces := true
@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element : ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 
@export_category("Usable Elements")
@export var usable_elements := {
	"blue": true,
	"purple": true,
	"magenta": true,
	"red": true,
	"orange": true,
	"yellow": true,
	"green": true,
	"cyan": true,
}
	
@onready var targeting_gizmo: Node3D = $TargetingGizmo
@onready var _timer := $Timer

var disabled := false:
	set(value):
		disabled = value
		_is_targeting = _is_targeting and value
		targeting_gizmo.clear_ghosts()

var _elements: Array
var _icons: Array
var _current_index := -1
var _is_targeting := false
# Scrolling mouse wheel once sends two signals. 
# This forces game to wait a few frames before accepting new events.
var _scroll_wheel_delay := .1

func _ready():
	_icons = []
	if Engine.is_editor_hint(): return

	_elements = []

	var i := 1
	for child in $CanvasLayer/VBoxContainer.get_children():
		#if not child is ElementIcon: continue

		var icon := (child.get_child(1) as ElementIcon)
		var el := icon.element
		var name := el.name.to_lower()
		child.get_child(0).text = str(i)
		
		if not usable_elements[name]: 
			child.hide()
			# In case _elements and _icons are out of sync.
			continue
		_elements.append(el)
		if el == element:
			child.modulate.a = 1
			_current_index = i - 1

		_icons.append(child)
		i += 1


func _process(delta: float) -> void:
	if _is_targeting and not disabled:
		targeting_gizmo.trace_spell(element)

func _unhandled_input(event: InputEvent) -> void:
	var prevIndex := _current_index
	if _is_targeting and event.is_action_pressed("cancel_simple_spell"):
		_is_targeting = false
		targeting_gizmo.clear_ghosts()
		get_window().set_input_as_handled()
	elif event.is_action_pressed("cast_simple_spell") and not disabled:
		_is_targeting = true
		targeting_gizmo.show()
	elif _is_targeting and event.is_action_released("cast_simple_spell") and not disabled:
		_is_targeting = false
		targeting_gizmo.clear_ghosts()
		cast_spell()
	
	elif event is InputEventMouseButton and _timer.is_stopped():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_current_index -= 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_current_index += 1
		else: return
		# Wait 3 frames before listening to the next scroll up command.
		_timer.start(_scroll_wheel_delay)
		_current_index %= len(_elements)

	elif event is InputEventKey: 
		if event.keycode >= KEY_1 and event.keycode <= KEY_8:
			_current_index = min(event.keycode - KEY_1, len(_elements) - 1)
		elif event.keycode >= KEY_KP_1 and event.keycode <= KEY_KP_8:
			_current_index = min(event.keycode - KEY_KP_1, len(_elements) - 1)
		

	if prevIndex >= 0 and prevIndex != _current_index:
		# Adjust the opacity of the previous icon.
		_icons[prevIndex].modulate.a = 0.5
		element = _elements[_current_index]
		_icons[_current_index].modulate.a = 1

func cast_spell() -> void:
	var projectile = ProjectilePrefab.instantiate()
	# Override number of bounces until destroy.
	if override_bounces: projectile.bounces = max_bounces

	projectile.look_at_from_position(global_position, targeting_gizmo.get_direction())
	get_tree().get_root().add_child(projectile)
	projectile.setup(global_position, element)
