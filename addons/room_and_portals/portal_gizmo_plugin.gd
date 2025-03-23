@tool
extends EditorNode3DGizmoPlugin

const RoomPortal = preload("RoomPortal.gd")

func _init():
	create_material("main", Color(0, 1, 1))
	create_handle_material("handles")


func _get_gizmo_name() -> String:
	return "PortalNode"


func _has_gizmo(node: Node) -> bool:
	return node is RoomPortal


func _redraw(gizmo) -> void:
	gizmo.clear()

	var node3d = gizmo.get_node_3d()
	if not node3d.door1 or not node3d.door2: return

	var lines := PackedVector3Array()

	lines.push_back(node3d.door1.position)
	lines.push_back(node3d.door2.position)

	var handles = PackedVector3Array()

	handles.push_back(node3d.door1.position)
	handles.push_back(node3d.door2.position)

	gizmo.add_lines(lines, get_material("main", gizmo), false)
	gizmo.add_handles(handles, get_material("handles", gizmo), [])


func _set_handle(gizmo: EditorNode3DGizmo, id: int, secondary: bool, camera: Camera3D, screenPos: Vector2) -> void:
	pass

