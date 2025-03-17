extends Area3D

## A list of items to give/take from player.
@export var items: Array[ItemSlot]
## A list of variables to set when player trips this.
@export var story_vars: Array[StoryVar]
## If true, trigger effects as soon as player touches CollisionShape.
## Otherwise, wait for signal (e.g. from a PuzzleBlock).
@export var trigger_on_contact := true

# An animation to play when player trips this trigger.
var animation_actor: AnimationActor

var puzzle_name: String

func _enter_tree() -> void:
	puzzle_name = "%s.%s" % [get_parent().name, name]
	for child in get_children():
		if child is AnimationActor:
			animation_actor = child


func _on_body_entered(body:Node3D) -> void:
	if not trigger_on_contact: return
	set_deferred("monitoring", false)
	trigger(body)

func trigger(body) -> void:
	print("StoryTrigger(%s) was activated." % puzzle_name)

	if not body.is_in_group("player"):
		body = get_tree().get_nodes_in_group("player")
		if len(body) > 0:
			body = body[0]
		else:
			push_warning("StoryTrigger(%s) could not find player." % puzzle_name)

	if animation_actor:
		animation_actor.play_animation(body)

	for item in items:
		Inventory.add_item(item.item, item.quantity)
	
	for v in story_vars:
		StoryManager.export_variable(v.name, v.value)

