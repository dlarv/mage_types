extends PhysicsBody3D
class_name Alchemic

func _init():
	add_to_group("alchemic")
	self.physics_material_override = PhysicsMaterial.new() 

# Virtual 
func transmute(element: ElementalType) -> ProjectileState: return null
