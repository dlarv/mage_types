# my_custom_gizmo.gd
extends EditorNode3DGizmo

func _redraw():
	clear()

	var portal = get_node_3d()
	if not portal.is_complete(): 
		print("Portal is not complete")
		return

	var lines := PackedVector3Array()
	var start = portal.get_door_position(0)
	var end = portal.get_door_position(1)
	print("Start(%s), End(%s)" % [ str(start), str(end) ])
	var mat = get_plugin().get_material("twoway", self) if not portal.is_one_way(-1) else get_plugin().get_material("oneway", self)

	lines.push_back(start)
	lines.push_back(end)
	add_lines(lines, mat, false)

