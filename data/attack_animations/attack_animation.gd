extends GPUParticles2D

func _process(delta):
	if not self.emitting:
		queue_free()
