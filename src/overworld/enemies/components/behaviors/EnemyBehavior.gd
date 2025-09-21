@tool
extends Node3D
class_name _EnemyBehavior
## Abstract class used to determine wild enemies movement and animations.

@export var sensor_size: float:
	set(val):
		sensor_size = val
		if not sensor: return
		sensor.set_size(val)
# How long to wait before asking NavigationAgent for player position
@export var navigation_recalc_delay: float
@export var base_speed := 100.0

var navigation_agent: NavigationAgent3D 
var sensor: Area3D 

var _player: Node3D

func _enter_tree() -> void:
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree)


func _ready() -> void:
	if Engine.is_editor_hint(): return

	var timer := Timer.new()
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)

	sensor.body_entered.connect(_on_body_entered)
	sensor.body_exited.connect(_on_body_exited)
	sensor.collision_mask = 32


#abstract
## Logic to determine enemy's next action should go in here.
func _on_timer_timeout() -> void: pass
#abstract
func get_next_position() -> Vector3: return Vector3.ZERO
#abstract
func get_next_animation() -> String: return ""

func _get_configuration_warnings() -> PackedStringArray:
	var output: PackedStringArray = []

	var hasArea3D := false
	var hasNavAgent := false
	for child in get_children():
		hasArea3D = child is Area3D or hasArea3D
		hasNavAgent = child is NavigationAgent3D or hasNavAgent

	if not hasArea3D:
		output.append("This node has no Area3D sensor, so it cannot know the player's position.")
	if not hasNavAgent:
		output.append("This node has no NavigationAgent3D, so it cannot pathfind to the player.")

	return output


func _on_child_exiting_tree(node:Node) -> void:
	if node is Area3D:
		sensor = null
	elif node is NavigationAgent3D:
		navigation_agent = null


func _on_child_entered_tree(node:Node) -> void:
	if node is Area3D:
		if sensor != node:
			print("Found sensor")
		sensor = node
		sensor.set_size(sensor_size)
	elif node is NavigationAgent3D:
		if navigation_agent != node:
			print("Found navigation agent")
		navigation_agent = node


func _on_body_entered(node: Node3D) -> void:
	Logger.append_world_log("Monster(%s) is now tracking the player." % get_parent().name)
	_player = node


func _on_body_exited(node: Node3D) -> void:
	Logger.append_world_log("Monster(%s) lost track of player." % get_parent().name)
	_player = null
