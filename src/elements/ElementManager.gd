@tool
extends Node 

const DEFAULT_CSV_PATH: String = "res://data/elemental_types/matchup_files/default.csv"
const SIMPLE_SIDE_EFFECTS_PATH: String = "res://data/elemental_types/matchup_files/simple.csv"

signal side_effects_updated(e1, e2)

var Blank: ElementalType = ElementalType.new()
var Blue: ElementalType
var Purple: ElementalType 
var Magenta: ElementalType 
var Red: ElementalType 
var Orange: ElementalType 
var Yellow: ElementalType 
var Green: ElementalType 
var Cyan: ElementalType 

@export var elements: Array[ElementalType] = []
@export var buff_multiplier := 1.5
@export var buff_effects: Array[AttackEffect]
@export var debuff_effects: Array[AttackEffect]

# Dict<string, Node>
var matchups := {}

func test()-> void:
	var actualResults = [
		# Red
		[ null, Yellow, Magenta, Orange, null, null, null, Magenta ],
	# Green 
		[ Yellow, null, Cyan, null, null, null, Yellow, Cyan ],
		# Blue
		[ Magenta, Cyan, null, null, null, Purple, Purple, null ],
		# Yellow
		[ Orange, null, null, null, Green, Red, Red, null ],
		# Cyan
		[ null, null, null, Green, null, Blue, null, Blue ],
		# Magenta
		[ null, null, Purple, Red, Blue, null, Red, Blue ],
		# Orange 
		[ null, Yellow, Purple, Red, null, Red, null, Magenta ],
		# Purple
		[ Magenta, Cyan, null, null, Blue, Blue, Magenta, null ]
	]
	var headers = [ Red, Green, Blue, Yellow, Cyan, Magenta, Orange, Purple ]
	var total = true
	for i in range(8):
		for j in range(8):
			var res = get_matchup(headers[i], headers[j])
			if(res != actualResults[i][j]): 
				push_warning("%s + %s != %s, == %s" % [headers[i].name, headers[j].name, actualResults[i][j].name, res.name ])

			total = total and res

	print("Final result: " + str(total))

func _enter_tree() -> void:
	force_load()

	if not Engine.is_editor_hint():
		for i in range(len(buff_effects)):
			if buff_effects[i] == null: continue
			buff_effects[i] = buff_effects[i].duplicate()
			buff_effects[i].strength *= buff_multiplier
		Settings.simplified_effects_toggled.connect(load_from_default_csv)
		
	load_from_default_csv(Settings.use_simplified_effects)
	


func force_load()-> void:
	if len(matchups.keys()) > 0: return

	for element in elements:
		match element.name.to_lower():
			"blue": 
				Blue = element
			"purple": 
				Purple = element
			"magenta": 
				Magenta = element
			"red": 
				Red = element
			"orange": 
				Orange = element
			"yellow": 
				Yellow = element
			"green": 
				Green = element
			"cyan": 
				Cyan = element
				

	matchups = {}
	var blue = ElementalNode.new(Blue)
	matchups[Blue.name] = blue
	var purple = ElementalNode.new(Purple)
	matchups[Purple.name] = purple
	var magenta = ElementalNode.new(Magenta)
	matchups[Magenta.name] = magenta
	var red = ElementalNode.new(Red)
	matchups[Red.name] = red
	var orange = ElementalNode.new(Orange)
	matchups[Orange.name] = orange
	var yellow= ElementalNode.new(Yellow)
	matchups[Yellow.name] = yellow
	var green = ElementalNode.new(Green)
	matchups[Green.name] = green
	var cyan = ElementalNode.new(Cyan)
	matchups[Cyan.name] = cyan

	blue.add_connection(Red, magenta)
	blue.add_connection(Green, cyan)
	blue.add_connection(Magenta, purple)
	blue.add_connection(Orange, purple)
	purple.add_connection(Red, magenta)
	purple.add_connection(Green, cyan)
	purple.add_connection(Cyan, blue)
	purple.add_connection(Magenta, blue)
	purple.add_connection(Orange, magenta)

	magenta.add_connection(Blue, purple)
	magenta.add_connection(Yellow, red)
	magenta.add_connection(Cyan, blue)
	magenta.add_connection(Orange, red)
	magenta.add_connection(Purple, blue)

	red.add_connection(Green, yellow)
	red.add_connection(Blue, magenta)
	red.add_connection(Yellow, orange)
	red.add_connection(Purple, magenta)

	orange.add_connection(Green, yellow)
	orange.add_connection(Blue, purple)
	orange.add_connection(Yellow, red)
	orange.add_connection(Magenta, red)
	orange.add_connection(Purple, magenta)

	yellow.add_connection(Red, orange)
	yellow.add_connection(Cyan, green)
	yellow.add_connection(Magenta, red)
	yellow.add_connection(Orange, red)

	green.add_connection(Red, yellow)
	green.add_connection(Blue, cyan)
	green.add_connection(Orange, yellow)
	green.add_connection(Purple, cyan)

	cyan.add_connection(Yellow, green)
	cyan.add_connection(Magenta, blue)
	cyan.add_connection(Purple, blue)

func get_element_from_name(name: String) -> ElementalType:
	# Ensure basic typos won't interfere.
	name = name.to_lower().strip_edges()
	for el in elements:
		if el.name.to_lower() == name:
			return el
	return null

func get_index_from_name(name: String) -> int:
	name = name.to_lower().strip_edges()
	for i in range(len(elements)):
		if elements[i].name.to_lower() == name:
			return i
	return -1

func get_matchup(element1: ElementalType, element2: ElementalType) -> ElementalType:
	if(element1.name == "Blank" || element2.name == "Blank"): return null

	var node = matchups[element1.name]
	var res = node.get_result(element2)
	return res

func get_side_effect(a: ElementalType, b: ElementalType) -> Array:
	if(a == Blank || b == Blank): return [null, null]
	return matchups[a.name].get_effect(b)

func get_all_matchups() -> Array:
	var output = []
	for node in matchups.values():
		for el in node.edges.keys():
			var edge = node.edges[el]
			var item = []
			item.append(node.element)
			item.append(el)
			item.append(edge.result.element)
			item.append(side_effect_to_index(edge.buff_effect, true))
			item.append(side_effect_to_index(edge.debuff_effect, false))

			output.append(item)
	return output

func set_side_effect_for(a: ElementalType, b: ElementalType, index: int, isBuff: bool) -> void:
	var effect
	if index == -1:
		effect = null
	else:
		effect = buff_effects[index] if isBuff else debuff_effects[index]
	matchups[a.name].set_effect(b, effect, isBuff)

	var effects = matchups[a.name].get_effect(b)
	var msg1 = effects[0].name if effects[0] != null else "null"
	var msg2 = effects[1].name if effects[1] != null else "null"

	side_effects_updated.emit(a, b)

func side_effect_to_index(effect: AttackEffect, isBuff: bool) -> int:
	if(effect == null): return -1
	var effects = buff_effects if isBuff else debuff_effects

	for i in range(len(effects)):
		if effect == effects[i]:
			return i
	return -1

func save_as_csv()-> String:
	var output= []
	for node in matchups.values():
		for key in node.edges.keys():
			var edge = node.edges[key]
			var line = "%s,%s,%s,%s,%s" % [ node.element.name, key.name, edge.result.element.name, str(side_effect_to_index(edge.buff_effect, true)), str(side_effect_to_index(edge.debuff_effect, false)) ]
			output.append(line)
	return "\n".join(output)

func load_from_csv(data: String) -> void:
	var lines = data.split("\n")

	var i = -1
	for line in lines:
		i += 1
		var values = line.split(",")
		if(len(values) == 1): continue
		var a = get_element_from_name(values[0]) 
		var b = get_element_from_name(values[1])

		var buffIndex = values[3].to_int()
		set_side_effect_for(a, b, buffIndex, true)

		var debuffIndex = values[4].to_int()
		set_side_effect_for(a, b, debuffIndex, false)

func load_from_default_csv(useSimplifiedEffects: bool)-> void:
	var path = DEFAULT_CSV_PATH if not useSimplifiedEffects else SIMPLE_SIDE_EFFECTS_PATH
	var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
	var data = file.get_as_text()
	load_from_csv(data)

class ElementalNode:
	var element : ElementalType = ElementManager.Blank
	# Dict<ElementalType, Edge>
	var edges = {}

	func _init(element: ElementalType) -> void:
		self.element = element
	
	func add_connection(element: ElementalType, result: ElementalNode) -> void:
		edges[element] = Edge.new(null, null, result)

	func get_result(other: ElementalType) -> ElementalType:
		var edge = edges.get(other, null)
		if(edge == null): return null
		return edge.result.element
	
	func get_effect(other: ElementalType) -> Array:
		var edge = edges.get(other, null)
		if(edge == null): return [null, null]
		return [edge.buff_effect, edge.debuff_effect]
	
	func set_effect(other: ElementalType, effect: AttackEffect, isBuff: bool) -> void:
		if(isBuff): edges[other].buff_effect = effect
		else: edges[other].debuff_effect = effect

	## Find the edge connecting this and end, then return its effect.
	func find_effect_for(end: ElementalType) -> AttackEffect:
		for edge in edges.values():
			if(edge.result.element == end): return edge.buff_effect
		return null

class Edge:
	var buff_effect: AttackEffect	
	var debuff_effect: AttackEffect 
	var result: ElementalNode 

	func _init(buffEffect: AttackEffect, debuffEffect: AttackEffect, end: ElementalNode) -> void:
		self.buff_effect = buffEffect
		self.debuff_effect = debuffEffect
		result = end
