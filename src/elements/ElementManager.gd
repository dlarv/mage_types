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
@export var attack_buff: _AttackEffect
@export var defense_buff: _AttackEffect
@export var speed_buff: _AttackEffect
@export var theme: Theme

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
			var res = get_side_effect(headers[i], headers[j])
			if res != actualResults[i][j]:
				push_warning("%s + %s != %s, == %s" % [
						headers[i].name, 
						headers[j].name, 
						actualResults[i][j].name, 
						res.name if res != null else "null"
						])
			total = total and res == actualResults[i][j]
	print("Side effects test: %s" % str(total)) 

func test_traversals() -> void:
	var length := 5
	var seq := [-1, 0, 0, 0, 0]
	var file := FileAccess.open("res://logs/sequences.csv", FileAccess.WRITE)

	var incrementSeq = func() -> void:
		for i in range(len(seq)):
			seq[i] += 1
			# Overflow?
			if seq[i] == 8:
				seq[i] = 0
				continue
			break
	var countNonZero = func(acc, num):
		if num > 0:
			acc += 1
		return acc
	# Returns false if seq should be discarded.
	# Sequences should have at most 2 repeating elements.
	var filterSeq = func() -> bool:
		var reachedMax := false
		for num in seq:
			var count := seq.count(num)
			if count > 2:
				return false
			if count >= 2:
				if reachedMax:
					return false
				reachedMax = true

		return true

	for i in range(pow(8, 5) - 1):
		incrementSeq.call()
		if not filterSeq.call(): 
			continue

		# Iterating through every combination of 5 lasers, where order matters.
		var lasers := [
			elements[seq[0]],
			elements[seq[1]],
			elements[seq[2]],
			elements[seq[3]],
			elements[seq[4]],
		]
		# Each row will be identified by "%s", where %s is the first letter of each laser's element's name.
		var header := "".join(lasers.map(func(x): return x.name[0]))
		var body := []
		# Get the average result for sequence.
		var averages := {
			elements[0]: 0,
			elements[1]: 0,
			elements[2]: 0,
			elements[3]: 0,
			elements[4]: 0,
			elements[5]: 0,
			elements[6]: 0,
			elements[7]: 0,
		}

		# Iterate over each element.
		# This will be what element the block starts out as.
		for startingElement in elements:
			var element := startingElement
			for laser in lasers:
				var e = get_matchup(element, laser)
				if e:
					element = e

			# Update the average
			averages[element] += 1.0/8.0
			body.append(element.name)
		
		# Print output in csv format.
		var output := "%s,%s,%s,%s" \
				% [ header, ",".join(body), ",".join(averages.values()), 
						str(averages.values().reduce(countNonZero, 0))] 
		print(output)
		file.store_line(output)

func _enter_tree() -> void:
	build()
	# test_transmutations()
	# test_side_effects()
	# test_traversals()
	
func build()-> void:
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

	# B
	blue.add_connection(Magenta, purple, attack_buff)
	blue.add_connection(Red, magenta, speed_buff)
	blue.add_connection(Orange, purple,	 attack_buff)
	blue.add_connection(Green, cyan, speed_buff)

	# B
	purple.add_connection(Magenta, blue, defense_buff)
	purple.add_connection(Red, magenta,	 defense_buff)
	purple.add_connection(Orange, magenta, defense_buff)
	purple.add_connection(Green, cyan, defense_buff)
	purple.add_connection(Cyan, blue, defense_buff)

	# M
	magenta.add_connection(Blue, purple, attack_buff)
	magenta.add_connection(Purple, blue, speed_buff)
	magenta.add_connection(Orange, red,	 attack_buff)
	magenta.add_connection(Yellow, red,	 attack_buff)
	magenta.add_connection(Cyan, blue, speed_buff)

	# R
	red.add_connection(Blue, magenta, defense_buff)
	red.add_connection(Purple, magenta,	 defense_buff)
	red.add_connection(Yellow, orange, speed_buff)
	red.add_connection(Green, yellow, defense_buff)

	orange.add_connection(Blue, purple,	 speed_buff)
	orange.add_connection(Purple, magenta, defense_buff)
	orange.add_connection(Magenta, red,	 speed_buff)
	orange.add_connection(Yellow, red, speed_buff)
	orange.add_connection(Green, yellow, defense_buff)

	yellow.add_connection(Magenta, red,	 attack_buff)
	yellow.add_connection(Red, orange, attack_buff)
	yellow.add_connection(Orange, red, attack_buff)
	yellow.add_connection(Cyan, green, attack_buff)

	green.add_connection(Blue, cyan, defense_buff)
	green.add_connection(Purple, cyan, defense_buff)
	green.add_connection(Red, yellow, defense_buff)
	green.add_connection(Orange, yellow, defense_buff)

	cyan.add_connection(Purple, blue, speed_buff)
	cyan.add_connection(Magenta, blue, speed_buff)
	cyan.add_connection(Yellow, green, attack_buff)

func get_element_from_name(name: String) -> ElementalType:
	# Ensure basic typos won't interfere.
	name = name.to_lower().strip_edges()
	if name == "blank":
		return Blank
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
	if not element1 or not element2 or element1.name == "Blank" || element2.name == "Blank": return null

	var node = matchups[element1.name]
	return node.get_result(element2)

func get_side_effect(a: ElementalType, b: ElementalType) -> _AttackEffect:
	if a.is_blank() || b.is_blank(): 
		return null
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

func side_effect_to_index(effect: _AttackEffect, isBuff: bool) -> int:
	if effect == null : 
		return -1
	elif effect == attack_buff:
		return 0
	elif effect == defense_buff:
		return 1
	else:
		return 2

func modify_color(element: Variant, newColor: Color) -> void:
	if element is String:
		element = get_element_from_name(element)
	element.main_color = newColor

	theme.set_color(element.name.to_lower(), "Control", newColor)
	var stylebox = theme.get_stylebox(element.name.to_lower(), "Control")
	stylebox.bg_color = newColor


func get_elemental_stylebox(element: Variant) -> StyleBox:
	if element is String:
		element = elements[get_index_from_name(element)]
	elif element is int:
		element = elements[element]

	return theme.get_stylebox(element.name.to_lower(), "Control")


class ElementalNode:
	var element : ElementalType = ElementManager.Blank
	# Dict<ElementalType, Edge>
	var edges := {}

	func _init(element: ElementalType) -> void:
		self.element = element
	
	func add_connection(element: ElementalType, result: ElementalNode, buff: _AttackEffect) -> void:
		edges[element] = Edge.new(buff, result)
	

	func get_result(other: ElementalType) -> ElementalType:
		var edge = edges.get(other, null)
		if edge == null or edge.result == null: 
			return null
		return edge.result.element
	
	func get_effect(other: ElementalType) -> _AttackEffect:
		var edge = edges.get(other, null)
		if edge == null: 
			return null
		return edge.buff_effect

	## Find the edge connecting this and end, then return its effect.
	func find_effect_for(end: ElementalType) -> _AttackEffect:
		for edge in edges.values():
			if(edge.result.element == end): return edge.buff_effect
		return null

class Edge:
	var buff_effect: _AttackEffect
	var result: ElementalNode 

	func _init(buffEffect: _AttackEffect, end: ElementalNode) -> void:
		self.buff_effect = buffEffect
		result = end
