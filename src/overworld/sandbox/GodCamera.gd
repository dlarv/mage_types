extends Camera3D

# Player or PhysicsPlayer
@export var player: PhysicsBody3D
@export var in_control := false
var _cam_rotation := Vector2()
var speed := 10.0

func _unhandled_input(event: InputEvent) -> void:
	if not in_control: return
	if event is InputEventMouseMotion:
		_cam_rotation.x += -event.relative.x
		_cam_rotation.y += -event.relative.y

func _physics_process(delta: float) -> void:
	if not in_control: return
	_cam_rotation.y = clamp(_cam_rotation.y, -90, 90)
	global_rotation.y = _cam_rotation.x * delta
	global_rotation.x = _cam_rotation.y * delta

	if Input.is_key_pressed(KEY_SPACE):
		position.y += speed * delta
	if Input.is_key_pressed(KEY_SHIFT):
		position.y -= speed * delta
	if Input.is_key_pressed(KEY_W):
		position -= transform.basis.z * speed * delta
	if Input.is_key_pressed(KEY_S):
		position += transform.basis.z * speed * delta
	if Input.is_key_pressed(KEY_A):
		position -= transform.basis.x * speed * delta
	if Input.is_key_pressed(KEY_D):
		position += transform.basis.x *  speed * delta
	
	

