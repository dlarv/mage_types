extends GPUParticles2D
class_name AttackAnimation

func _ready():
	emitting = true

func _process(delta):
	if not self.emitting:
		queue_free()

func superimpose(user: CanvasItem, target: CanvasItem, is_flipped: bool):
	pass
