@tool
extends MagiClay

var grabbable: Grabbable
var _prev_parent: Node3D = null

func _ready() -> void:
	super._ready()
	grabbable = find_child("Grabbable", true)
	if not grabbable.is_connected("grabbed", _on_grabbed):
		grabbable.grabbed.connect(_on_grabbed)


func _on_child_entered_tree(node: Node) -> void:
	if node is Grabbable:
		if not node.is_connected("grabbed", _on_grabbed):
			node.grabbed.connect(_on_grabbed)
			

func _on_grabbed(obj: Node3D, player: Node3D) -> void:
	if _prev_parent == null:
		_prev_parent = get_parent()
		player.pickup_object(self, grabbable, true)
	else:
		_on_dropped(obj, player)
		player.pickup_object(self, grabbable, false)

func _on_dropped(obj: Node3D, player: Node3D) -> void:
	if player.held_object == self:
		call_deferred("drop")
		player.pickup_object(self, grabbable, false)

func drop() -> void:
	reparent(_prev_parent)
	_prev_parent = null
	global_position = global_position.snapped(Vector3(0.5, 0.5, 0.5))

