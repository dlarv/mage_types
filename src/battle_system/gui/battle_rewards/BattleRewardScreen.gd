extends PanelContainer

signal pressed()

const Display := preload("res://src/battle_system/gui/battle_rewards/actor_display.tscn")
const DELAY := 0.0


func show_results(actors: Array[BattleActor], xp: float, otherRewards: Array[ItemSlot]=[]) -> void:
	var displays := []
	for actor in actors:
		var display := Display.instantiate()
		%HBoxContainer.add_child(display)
		display.set_actor(actor)
		displays.append(display)

	await get_tree().create_timer(DELAY).timeout

	for display: Control in displays:
		display.add_xp(xp)


func _on_finish_button_pressed() -> void:
	pressed.emit()
