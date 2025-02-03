@tool
extends Node 

const DEFAULT_CSV_PATH: String = "res://data/elemental_types/matchup_files/default.csv"
const SIMPLE_SIDE_EFFECTS_PATH: String = "res://data/elemental_types/matchup_files/simple.csv"

var Blank := ElementalType.new()
var Blue: ElementalType
var Purple: ElementalType 
var Magenta: ElementalType 
var Red: ElementalType 
var Orange: ElementalType 
var Yellow: ElementalType 
var Green: ElementalType 
var Cyan: ElementalType 

@export var elements: Array[ElementalType] = []
# @export var buff_multiplier := 1.5
# @export var buff_effects: Array[AttackEffect]
# @export var debuff_effects: Array[AttackEffect]
@export var attack_buff: AttackEffect
@export var defense_buff: AttackEffect
@export var speed_buff: AttackEffect
@export var resistance_mod := 0.5
@export var weakness_mod := 2

# Dict<string, Node>
var matchups := {}

func test_transmutations()-> void:
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
				push_warning("%s + %s != %s, == %s" % [
						headers[i].name, 
						headers[j].name, 
						actualResults[i][j].name, 
						res.name if res != null else "null"
						])

			total = total and res == actualResults[i][j]


func test_resistances() -> void:
	var g := resistance_mod
	var r := weakness_mod
	var b := 1

	var actualResults = [
		# Blue
		[ b, b, g, g, r, b, r, b ],
		# Purple
		[ r, r, g, r, b, b, b, g ],
		# Magenta
		[ g, g, b, g, b, b, b, g ],
		# Red
		[ r, b, r, b, b, g, b, b ],
		# Orange
		[ b, r, r, b, b, g, b, r ],
		# Yellow
		[ g, r, b, g, b, g, b, g ],
		# Green
		[ g, r, g, r, r, r, r, g ],
		# Cyan
		[ b, b, g, g, g, r, b, b],
	]
	var headers = [ Blue, Purple, Magenta, Red, Orange, Yellow, Green, Cyan ]
	var total = true
	for i in range(8):
		for j in range(8):
			var res = get_resistance(headers[i], headers[j])
			if res != actualResults[i][j]:
				push_warning("%s + %s != %f, == %f" % [headers[i].name, headers[j].name, actualResults[i][j], res ])
			total = total and res == actualResults[i][j]


func test_side_effects() -> void:
	var a := attack_buff
	var d := defense_buff
	var s := speed_buff
	var n = null

	var actualResults = [
		# R
		[ n, d, d, s, n, n, n, d ],
		# G
		[ d, n, d, n, n, n, d, d ],
		# B
		[ s, s, n, n, n, a, a, n ],
		# Y
		[ a, n, n, n, a, a, a, n ],
		# C
		[ n, n, n, a, n, s, n, s ],
		# M
		[ n, n, a, a, s, n, a, s ],
		# O
		[ n, d, s, s, n, s, n, d ],
		# P
		[ d, d, n, n, d, d, d, n ],
	]

	var total = true
	var headers = [ Red, Green, Blue, Yellow, Cyan, Magenta, Orange, Purple ]
	for i in range(8):
		for j in range(8):
			var res = get_side_effect(headers[i], headers[j])[0]
			if res != actualResults[i][j]:
				push_warning("%s + %s != %s, == %s" % [
						headers[i].name, 
						headers[j].name, 
						actualResults[i][j].name, 
						res.name if res != null else "null"
						])
			total = total and res == actualResults[i][j]


func _enter_tree() -> void:
	force_load()

	test_transmutations()
	test_resistances()
	test_side_effects()
	
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
				
	# Temp vars for brevity
	var wm := weakness_mod
	var rm := resistance_mod

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

	# B
	blue.add_resistance_connection(Purple, wm)
	blue.add_connection(Magenta, purple, attack_buff, rm)
	blue.add_connection(Red, magenta, speed_buff, wm)
	blue.add_connection(Orange, purple,	 attack_buff)
	blue.add_resistance_connection(Yellow, rm)
	blue.add_connection(Green, cyan, speed_buff, rm)
	# C

	# B
	purple.add_resistance_connection(Purple, wm)
	purple.add_connection(Magenta, blue, defense_buff, rm)
	purple.add_connection(Red, magenta,	 defense_buff)
	purple.add_connection(Orange, magenta, defense_buff, wm)
	purple.add_resistance_connection(Yellow, wm)
	purple.add_connection(Green, cyan, defense_buff, wm)
	purple.add_connection(Cyan, blue, defense_buff)

	magenta.add_connection(Blue, purple, attack_buff, rm)
	magenta.add_connection(Purple, blue, speed_buff, rm)
	# M
	magenta.add_resistance_connection(Red, wm)
	magenta.add_connection(Orange, red,	 attack_buff, wm)
	magenta.add_connection(Yellow, red,	 attack_buff)
	magenta.add_resistance_connection(Green, rm)
	magenta.add_connection(Cyan, blue, speed_buff, rm)

	red.add_connection(Blue, magenta, defense_buff, rm)
	red.add_connection(Purple, magenta,	 defense_buff, wm)
	red.add_resistance_connection(Magenta, rm)
	# R_
	# O_
	red.add_connection(Yellow, orange, speed_buff, rm)
	red.add_connection(Green, yellow, defense_buff, wm)
	red.add_resistance_connection(Cyan, rm)

	orange.add_connection(Blue, purple,	 speed_buff, wm)
	orange.add_connection(Purple, magenta, defense_buff)
	orange.add_connection(Magenta, red,	 speed_buff)
	# R
	# O
	orange.add_connection(Yellow, red, speed_buff)
	orange.add_connection(Green, yellow, defense_buff, wm)
	orange.add_resistance_connection(Cyan, rm)

	# B
	# P
	yellow.add_connection(Magenta, red,	 attack_buff)
	yellow.add_connection(Red, orange, attack_buff, rm)
	yellow.add_connection(Orange, red, attack_buff, rm)
	yellow.add_resistance_connection(Yellow, rm)
	yellow.add_resistance_connection(Green, wm)
	yellow.add_connection(Cyan, green, attack_buff, wm)

	green.add_connection(Blue, cyan, defense_buff, wm)
	green.add_connection(Purple, cyan, defense_buff)
	# M
	green.add_connection(Red, yellow, defense_buff)
	green.add_connection(Orange, yellow, defense_buff)
	# Y
	green.add_resistance_connection(Green, wm)
	# C

	# B
	cyan.add_connection(Purple, blue, speed_buff, rm)
	cyan.add_connection(Magenta, blue, speed_buff, rm)
	# R
	cyan.add_resistance_connection(Orange, wm)
	cyan.add_connection(Yellow, green, attack_buff, rm)
	cyan.add_resistance_connection(Green, rm)
	# C

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
	return node.get_result(element2)

func get_resistance(element1: ElementalType, element2: ElementalType) -> float:
	if(element1.name == "Blank" || element2.name == "Blank"): return 1

	var node = matchups[element2.name]
	return node.get_resistance(element1)

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


func side_effect_to_index(effect: AttackEffect, isBuff: bool) -> int:
	if effect == null : 
		return -1
	elif effect == attack_buff:
		return 0
	elif effect == defense_buff:
		return 1
	else:
		return 2


class ElementalNode:
	var element : ElementalType = ElementManager.Blank
	# Dict<ElementalType, Edge>
	var edges := {}

	func _init(element: ElementalType) -> void:
		self.element = element
	
	func add_connection(element: ElementalType, result: ElementalNode, buff: AttackEffect, resist:=1.0) -> void:
		edges[element] = Edge.new(buff, result, resist)
	
	func add_resistance_connection(element: ElementalType, resist: float) -> void:
		if element in edges.keys(): 
			edges.resistance = resist
			return
		edges[element] = Edge.new(null, null, resist)

	func get_result(other: ElementalType) -> ElementalType:
		var edge = edges.get(other, null)
		if edge == null or edge.result == null: 
			return null
		return edge.result.element
	
	func get_effect(other: ElementalType) -> Array:
		var edge = edges.get(other, null)
		if edge == null : return [null, null]
		return [edge.buff_effect, null]

	func get_resistance(other: ElementalType) -> float:
		var edge = edges.get(other)
		if edge == null: return 1
		return edge.resistance

	## Find the edge connecting this and end, then return its effect.
	func find_effect_for(end: ElementalType) -> AttackEffect:
		for edge in edges.values():
			if(edge.result.element == end): return edge.buff_effect
		return null

class Edge:
	var buff_effect: AttackEffect	
	var result: ElementalNode 
	var resistance: float

	func _init(buffEffect: AttackEffect, end: ElementalNode, resist: float) -> void:
		self.buff_effect = buffEffect
		self.resistance = resist
		result = end
