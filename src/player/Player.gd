extends CharacterBody3D 
class_name Player 

signal BattleStarted(allies, items, enemy);

@export
var battle_actor : BattleActor 
var Party;
var inventory : Inventory 

@export_category("Movement")
@export
var Speed : float = 10.0
@export
var JumpVelocity : float = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();

func _physics_process(delta) -> void:
	var vel = velocity;

	# Add the gravity.
	if !is_on_floor():
		vel.y -= gravity * delta;

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		vel.Y = JumpVelocity;

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized();
	if direction != Vector3.ZERO:
		vel.x = direction.x * Speed;
		vel.z = direction.z * Speed;
	else:
		vel.x = move_toward(velocity.x, 0, Speed);
		vel.z = move_toward(velocity.z, 0, Speed);

	velocity = vel;
	move_and_slide();

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i);

		if collision.get_collider().is_in_group("enemy"):
			BattleStarted.emit(Party, inventory.GetBattleItems(), collision.get_collider())
