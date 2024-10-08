extends Control

@export var settings_menu: Control
@export var save_game_menu: Control
@export var load_game_menu: Control

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
		get_window().set_input_as_handled()
		visible = not visible

func _on_open_settings_button_pressed() -> void:
	settings_menu.show()

func _on_save_game_button_pressed() -> void:
	save_game_menu.show()

func _on_load_game_button_pressed() -> void:
	load_game_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
