extends CharacterBody3D 
class_name Player 

signal battle_started(allies, items, enemies)

@export var battle_actor: BattleActor 
@export var party: Array[BattleActor]
@export var inventory: Inventory 
@export var player_menu: Control 

@export_category("Movement")
@export var speed : float = 10.0
@export var jump_velocity : float = 4.5
@export_category("Movepool")
@export var movepool: Movepool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9#ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();

func _ready() -> void:
	player_menu.init_inventory(inventory)
	party.insert(0, battle_actor)

func _physics_process(delta) -> void:
	var vel = velocity;

	# Add the gravity.
	if !is_on_floor():
		vel.y -= gravity * delta;

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		vel.y = jump_velocity;

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized();
	if direction != Vector3.ZERO:
		vel.x = direction.x * speed;
		vel.z = direction.z * speed;
	else:
		vel.x = move_toward(velocity.x, 0, speed);
		vel.z = move_toward(velocity.z, 0, speed);

	velocity = vel;
	move_and_slide();

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i);
		var enemy = collision.get_collider()

		if enemy.is_in_group("enemy"):
			battle_started.emit(party, inventory.get_battle_items(), enemy)

