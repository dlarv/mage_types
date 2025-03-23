@tool
extends EditorNode3DGizmoPlugin

const RoomPortal = preload("RoomPortal.gd")
const PortalGizmo = preload("PortalGizmo.gd")

func _init():
	create_material("twoway", Color(0, 1, 1))
	create_material("oneway", Color(1, 1, 0))
	create_handle_material("handles")


func _get_gizmo_name() -> String:
	return "PortalNode"

func _create_gizmo(node: Node3D) -> PortalGizmo:
	if node is RoomPortal:
		return PortalGizmo.new()
	return null

func _has_gizmo(node: Node) -> bool:
	return node is RoomPortal
