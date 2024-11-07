extends Resource
class_name ProjectileState

@export var result_element: ElementalType
@export var extra_bounces: int

func _init(element: ElementalType=null, bounces:=0):
	result_element = element
	extra_bounces = bounces

func apply_changes(projectile: RigidBody3D) -> void:
	if result_element != null:
		projectile.element = result_element
	projectile.bounces += extra_bounces
