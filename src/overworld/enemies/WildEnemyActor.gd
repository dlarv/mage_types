@tool
extends MagiClay

var state_machine: _EnemyBehavior

func _ready() -> void:
	for child in get_children():
		if child is _EnemyBehavior:
			state_machine = child


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	self.velocity = state_machine.get_next_position() * delta
	_move_and_slide()


func _move_and_slide() -> void:
	var s: Node3D = self
	s.move_and_slide()
