extends PanelContainer

signal pressed()
signal skip()

const Display := preload("res://src/battle_system/gui/battle_rewards/actor_display.tscn")

var display_count := 0
var _animating_xp := false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("close_menu"):
		get_viewport().set_input_as_handled()
		pressed.emit()


func show_results(actors: Array[BattleActor], xp: float, otherRewards: Array[ItemSlot]=[]) -> void:
	var displays := []
	for actor in actors:
		var display := Display.instantiate()
		%HBoxContainer.add_child(display)
		display.set_actor(actor)
		displays.append(display)

		var dict := actor.update_alignment()
		if dict.is_empty() or dict.element == null: continue

		var msg: String
		if dict.aligned:
			msg = "[center]!!!!\n%s aligned to [el]%s[/el]![/center]" % [actor.name, dict.element.name]
		else:
			msg = "[center]!!\n%s core changed to [el]%s[/el]![/center]" % [actor.name, dict.element.name]

		%RealignmentDisplayParent.show()
		await %RealignmentDisplay.display_message_blocking(msg)
		%RealignmentDisplayParent.hide()

	%ItemHeader.visible = len(otherRewards)
	for slot in otherRewards:
		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var label := Label.new()
		label.text = slot.item.name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var label2 := Label.new()
		label2.text = "x%d" % slot.quantity
		label2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		hbox.add_child(label)
		hbox.add_child(label2)
		%ItemScroller.add_child(hbox)

	_animating_xp = true
	display_count = len(displays)
	for display: Control in displays:
		skip.connect(display._next.bind(true))
		display.add_xp(xp)
		display.next.connect(_on_animation_finished)


func _on_finish_button_pressed() -> void:
	if _animating_xp:
		skip.emit()
	else:
		pressed.emit()


func _on_animation_finished(_b: bool) -> void:
	display_count -= 1
	if display_count <= 0:
		_animating_xp = false
