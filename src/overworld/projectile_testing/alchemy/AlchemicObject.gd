@tool
extends Alchemic

@export_enum("blank", "blue", "purple", "magenta", "red", "orange", "yellow", "green", "cyan")
var _element: String = "blank":
	set(value):
		_element = value
		element = ElementManager.get_element_from_name(value)
var element : ElementalType = ElementManager.Blank:
	set(value): 
		if value == null:
			value = ElementManager.Blank
		element = value 
		if _material == null: return
		_material.albedo_color = element.main_color

var _material: BaseMaterial3D = null


func _init():
	super._init()
	_material = StandardMaterial3D.new()


func _ready():
	$MeshInstance3D.set_surface_override_material(0, _material)


## Tries to transmute this object.
## Returns null if 
func transmute(element: ElementalType) -> ElementalType:
	var reaction = ElementManager.get_matchup(self.element, element)
	if reaction != null: 
		self.element = reaction
	return null 
