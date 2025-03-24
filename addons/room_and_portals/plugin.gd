@tool
extends EditorPlugin

const PortalGizmoPlugin = preload("portal_gizmo_plugin.gd")

var gizmo_plugin := PortalGizmoPlugin.new()


func _enter_tree() -> void:
	add_node_3d_gizmo_plugin(gizmo_plugin)
	add_custom_type("RoomPortal", "Area3D", preload("RoomPortal.gd"), preload("res://assets/sprites/icon.svg"))


func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
	remove_custom_type("RoomPortal")
