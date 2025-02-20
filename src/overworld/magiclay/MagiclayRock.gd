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
		# reparent(player)
		player.pickup_object(self, grabbable, true)
		if not obj.is_connected("dropped",_on_dropped):
			obj.call_deferred("connect", "dropped", _on_dropped)
	else:
		reparent(_prev_parent)
		_prev_parent = null
		player.pickup_object(self, grabbable, false)
		if obj.is_connected("dropped",_on_dropped):
			obj.call_deferred("disconnect", "dropped", _on_dropped)
	

func _on_dropped(obj: Node3D, player: Node3D) -> void:
	if player.held_object == self:
		call_deferred("reparent", _prev_parent)
		_prev_parent = null
		player.pickup_object(self, grabbable, false)

		if obj.is_connected("dropped",_on_dropped):
			obj.call_deferred("disconnect", "dropped", _on_dropped)
