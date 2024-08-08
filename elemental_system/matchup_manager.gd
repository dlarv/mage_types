@tool
extends Node

var NO_MATCH: Matchup = Matchup.new(null, ElementalEffect.Effect.NONE, 0)

# [ element 1, element 2, result ]
var matchups = {}
var elements = []

func _ready():
	if not Engine.is_editor_hint():
		load_from_file("res://elemental_system/matchup_data_files/default.txt")

func add_matchup(a: ElementalType, 
		b: ElementalType, 
		result: ElementalType, 
		effect: ElementalEffect.Effect=ElementalEffect.Effect.NONE,
		modifier: int = 0):
	var element1 = ElementalType.max(a, b)
	var element2 = ElementalType.min(a, b)
	matchups[[element1.type_name, element2.type_name]] = \
		Matchup.new(result, effect, modifier)

func get_matchup(a: ElementalType, b: ElementalType):
	if a == null or b == null: return NO_MATCH
	
	var element1 = ElementalType.max(a, b)
	var element2 = ElementalType.min(a, b)
	return matchups.get( \
		[element1.type_name, element2.type_name], \
		NO_MATCH
		)

func get_element_by_name(name: String):
	for el in elements:
		if el.type_name == name:
			return el
	return null

func get_index_from_name(name: String):
	var i = 0
	for el in elements:
		if el.type_name == name:
			return i
		i += 1
	return -1


func add_element(element: ElementalType):
	#elements[element.type_name] = element.color
	elements.append(element)
	
func load_from_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null: return
	matchups = {}
	
	var line = file.get_csv_line()
	var i = 0
	elements = []
	while i < len(line):
		var name = line[i]
		var color = line[i + 1]
		elements.append(ElementalType.new(name, Color.hex64(int(color))))
		i += 2
	
	var line_num = 0
	while not file.eof_reached():
		line = file.get_csv_line()
		line_num += 1
		if len(line) == 1 and line[0].is_empty():
			continue
		if len(line) != 8:
			push_warning("Error reading elemental matchup data on line %d. Expected 6 elements, found %d" % [line_num - 1, len(line)])
			continue
		
		var name1 = line[0]
		var color1 = Color.hex64(int(line[1]))
		var element1 = ElementalType.new(name1, color1)
		
		var name2 = line[2]
		var color2 = Color.hex64(int(line[3]))
		var element2 = ElementalType.new(name2, color2)
		
		var name3 = line[4]
		var color3
		var element3 = null
		if len(name3) != 0:
			color3 = Color.hex64(int(line[5]))
			element3 = ElementalType.new(name3, color3)
		var effect = int(line[6])
		var modifier = int(line[7])

		add_matchup(element1, element2, element3, effect, modifier)

func write_to_file(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null: return
	
	var output = []
	for el in elements:
		output.append(el.type_name)
		output.append(el.color.to_rgba64())
	file.store_csv_line(output)
	
	for key in matchups.keys():
		# These values can be null
		var col = 0
		var name = ""
		if matchups[key].element != null:
			col = matchups[key].element.color.to_rgba64()
			name = matchups[key].element.type_name
		
		output = [
			key[0],
			get_element_by_name(key[0]).color.to_rgba64(),
			key[1], 
			get_element_by_name(key[1]).color.to_rgba64(),
			name, 
			col,
			matchups[key].effect,
			matchups[key].modifier
		]
		print(output)
		file.store_csv_line(output)



