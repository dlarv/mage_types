extends Node2D
class_name BattleActionAnimation

@export var animation: GPUParticles2D
@export var start: Vector2i
@export var end: Vector2i

func _ready():
	animation.emitting = true;

func _process(delta):
	if not animation.emitting:
		queue_free()

func _play(start: Vector2i, end: Vector2i, element=null):
	set_elemental_tint(element)
	position = end 
	self.start = start
	self.end = end

func long_play():
	# Used for testing.
	# Will c# wait to continue for this script to execute before continuing?
	await get_tree().create_timer(3).timeout
	print("Here for GD")

func set_elemental_tint(element):
	if element == null: 
		return
	if element is Color:
		self.modulate = element
	else:
		self.modulate = element.MainColor
