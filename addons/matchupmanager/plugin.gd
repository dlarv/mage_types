@tool
extends EditorPlugin

var plugin


var dock

func _enter_tree():
	dock = preload("res://addons/matchupmanager/matchup_manager.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UR, dock)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
