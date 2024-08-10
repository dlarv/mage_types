@tool
extends Resource
class_name BattleActor

const MIN_STAT: int = 10
const MAX_STAT: int = 1000

@export var actor_name: String
var sprite: Sprite2D
@export_enum("Red", "Green", "Blue", "Yellow", "Magenta", "Cyan", "Orange", "Purple", "Pink")
var element1: String:
	set(val):
		element1 = val
		primary_element =  MatchupManager.get_element_by_name(val)
@export_enum("None", "Red", "Green", "Blue", "Yellow", "Magenta", "Cyan", "Orange", "Purple", "Pink")
var element2: String:
	set(val):
		element2 = val
		if val == "None": 
			secondary_element = null
		else:
			secondary_element =  MatchupManager.get_element_by_name(val)
var primary_element: ElementalType
var secondary_element: ElementalType
@export var attacks: Array[Attack] = []

@export_category("Stats")
@export_range(MIN_STAT, MAX_STAT)
var hp: int = MIN_STAT: 
	set(val):
		hp = val
@export_range(MIN_STAT, MAX_STAT) 
var attack: int = MIN_STAT: 
	set(val):
		attack = val
@export_range(MIN_STAT, MAX_STAT) 
var defense: int = MIN_STAT: 
	set(val):
		defense = val
@export_range(MIN_STAT, MAX_STAT) 
var speed: int = MIN_STAT: 
	set(val):
		speed = val

static func create(actor_name: String, element1: ElementalType, element2: ElementalType, attacks: Array, stats: Dictionary):
	var texture = GradientTexture2D.new()
	var gradient = Gradient.new()
	texture.height = 200
	texture.width = 200
	texture.gradient = gradient
	
	gradient.set_color(0, element1.color)
	var color2
	if element2 == null:
		color2 = Color.WHITE
	else:
		color2 = element2.color
	gradient.set_color(1, color2)
	
	var sprite = Sprite2D.new()
	sprite.texture = texture

	return Fighter.new(actor_name, element1, element2, attacks, stats, sprite)


func get_stats() -> Dictionary:
	return {
		"hp": hp,
		"defense": defense,
		"attack": attack,
		"speed": speed,
	}


class Fighter:
	var actor_name: String
	var primary_element: ElementalType
	var secondary_element: ElementalType
	var attacks: Array
	var hp: int
	var current_hp: int
	var attack: int
	var defense: int
	var speed: int
	var stats: Dictionary
	var sprite: Sprite2D
	
	func _init(actor_name: String, \
			element1: ElementalType, \
			element2: ElementalType, \
			attacks: Array, \
			stats: Dictionary, \
			sprite: Sprite2D):
		
		hp = stats.get("hp", MIN_STAT)
		current_hp = hp
		attack = stats.get("attack", MIN_STAT)
		defense = stats.get("defense", MIN_STAT)
		speed = stats.get("speed", MIN_STAT)
		self.stats = stats.duplicate(true)
		
		self.actor_name = actor_name
		primary_element = element1
		secondary_element = element2
		self.attacks = attacks
		self.sprite = sprite

	func transmute(element1: Matchup, element2: Matchup=null):
		if not element1.is_empty():
			primary_element = element1.element
			if sprite.texture is GradientTexture2D:
				sprite.texture.gradient.set_color(0, primary_element.color)
		if element2 != null and not element2.is_empty():
			secondary_element = element2.element
			if sprite.texture is GradientTexture2D:
				sprite.texture.gradient.set_color(1, secondary_element.color)
