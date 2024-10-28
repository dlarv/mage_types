extends Node2D
class_name BattleActionAnimation

signal animation_finished()

@export var animation: GPUParticles2D
@export var start: Vector2i
@export var end: Vector2i

func _ready():
	animation.emitting = true

func _process(delta):
	if not animation.emitting:
		animation_finished.emit()
		queue_free()

func _play(start: Vector2i, end: Vector2i, parent: Node2D, element=null) -> BattleActionAnimation:
	set_elemental_tint(element)
	position = end 
	self.start = start
	self.end = end
	parent.add_child(self)
	return self

func set_elemental_tint(element):
	if element == null: 
		return
	if element is Color:
		self.modulate = element
	else:
		self.modulate = element.main_color
