@tool
extends Area3D

@export var rewards: Array[Item]
@export var auto_teach_spells := false

var _collision_shape: CollisionShape3D:
	get:
		for child in get_children():
			if child is CollisionShape3D:
				return child
		return null
var _already_triggered := false:
	set(value):
		_already_triggered = value
		if _collision_shape == null: return
		var lambda = func():  _collision_shape.disabled = _already_triggered
		lambda.call_deferred()

func _on_body_entered(body: Node3D) -> void:
	if _already_triggered or not body is Player: return
	_already_triggered = true

	var i = len(body.battle_actor.attacks)
	for reward in rewards:
		Inventory.add(reward, 1)
		if auto_teach_spells and reward is SpellScroll:
			body.battle_actor.learn_spell(reward, i)

		(body as Player).player_menu.characters_menu.player_screen._spells_menu.set_moveset_slot(reward, i)
		i += 1
		
