@tool
extends MagiClay

const MATERIALS := {
	"Magenta": preload("physics_materials/magenta.tres"),
}

var _area_3d: Area3D

func _enter_tree() -> void:
	super._enter_tree()

	if get_parent().is_in_group("player"):
		self.physics_material_override = null
	elif MATERIALS.has(element.name):
		self.physics_material_override = MATERIALS[element.name]

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return

	var area3d = find_child("Area3D", false)
	_area_3d = area3d
	if not area3d: return
	if not area3d.body_entered.is_connected(_on_body_entered):
		area3d.body_entered.connect(_on_body_entered)
	if not area3d.body_exited.is_connected(_on_body_exited):
		area3d.body_exited.connect(_on_body_exited)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	pass


func set_element(e: ElementalType, randVal:=-2, force:=false) -> bool:
	if not super.set_element(e, randVal, force): return false
	if Engine.is_editor_hint(): return true

	if MATERIALS.has(e.name):
		self.physics_material_override = MATERIALS[e.name]
	return true


func _on_body_entered(body: Node3D) -> void:
	if not body is Player or get_parent() == body: return
	match element:
		ElementManager.Magenta:
			var vel = -body.velocity * 3
			var dir = abs(global_position.direction_to(body.global_position).normalized())
			if dir.y > dir.x and dir.y > dir.z:
				body.outside_forces.y += 10
			else:
				body.outside_forces += vel
				body.block_control(0.5)


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"): return

	match element:
		pass


