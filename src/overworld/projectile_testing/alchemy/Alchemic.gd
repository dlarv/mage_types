extends PhysicsBody3D
class_name Alchemic

func _init():
	add_to_group("alchemic")

# Virtual 
func transmute(element: ElementalType) -> ElementalType: return null
