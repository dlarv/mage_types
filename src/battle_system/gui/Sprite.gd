extends Sprite2D
class_name Sprite 
@export
var sprite : Sprite2D = null
var use_gradient_sprite = false

func set_gradient_sprite(element1: ElementalType, element2: ElementalType) -> void:
	var grad = Gradient.new()
	use_gradient_sprite = true

	if element1 != null:
		grad.set_color(0, element1.main_color)
	if element2 != null:
		grad.set_color(1, element2.main_color)
	
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	texture = tex

func set_element(id: int, element: ElementalType) -> void:
	if use_gradient_sprite:
		texture.gradient.set_color(id, element.main_color)
