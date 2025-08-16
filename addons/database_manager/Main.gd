@tool
extends TabContainer

const Row := preload("attack_manager/SpreadsheetRow.gd")


func _on_attack_manager_row_selected(row: Row) -> void:
	current_tab = 1
	$Builder.open_row(row)


func _on_builder_back_button_pressed() -> void:
	current_tab = 0
