@tool
extends Node 
const DEFAULT_CSV_PATH: String = "res://data/elemental_types/matchup_files/default.csv"

var Blank : ElementalType = ElementalType.new()
var Blue : ElementalType
var Purple : ElementalType 
var Magenta : ElementalType 
var Red : ElementalType 
var Orange : ElementalType 
var Yellow : ElementalType 
var Green : ElementalType 
var Cyan : ElementalType 

@export
# ElementalType[]
var Elements: Array[ElementalType] 
@export
# AttackEffect[]
var BuffEffects = []
@export
# AttackEffect[]
var DebuffEffects = []

# Dict<string, Node>
var matchups = {}

func _ready()-> void:
	pass
func Test()-> void:
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
			var res = GetMatchup(headers[i], headers[j]) == actualResults[i][j]
			if(!res): push_warning("%s + %s != %s" % [headers[i], headers[j], actualResults[i][j] ])
			total &= res
	print("Final result: " + str(total))

func _enter_tree()-> void:
	ForceLoad()
	LoadFromDefaultCSV()

func ForceLoad()-> void:
	for element in Elements:
		match element.Name.to_lower():
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
	matchups[Blue.Name] = blue
	var purple = ElementalNode.new(Purple)
	matchups[Purple.Name] = purple
	var magenta = ElementalNode.new(Magenta)
	matchups[Magenta.Name] = magenta
	var red = ElementalNode.new(Red)
	matchups[Red.Name] = red
	var orange = ElementalNode.new(Orange)
	matchups[Orange.Name] = orange
	var yellow= ElementalNode.new(Yellow)
	matchups[Yellow.Name] = yellow
	var green = ElementalNode.new(Green)
	matchups[Green.Name] = green
	var cyan = ElementalNode.new(Cyan)
	matchups[Cyan.Name] = cyan

	blue.AddConnection(Red, magenta)
	blue.AddConnection(Green, cyan)
	blue.AddConnection(Magenta, purple)
	blue.AddConnection(Orange, purple)

	purple.AddConnection(Red, magenta)
	purple.AddConnection(Green, cyan)
	purple.AddConnection(Cyan, blue)
	purple.AddConnection(Magenta, blue)
	purple.AddConnection(Orange, magenta)

	magenta.AddConnection(Blue, purple)
	magenta.AddConnection(Yellow, red)
	magenta.AddConnection(Cyan, blue)
	magenta.AddConnection(Orange, red)
	magenta.AddConnection(Purple, blue)

	red.AddConnection(Green, yellow)
	red.AddConnection(Blue, magenta)
	red.AddConnection(Yellow, orange)
	red.AddConnection(Purple, magenta)

	orange.AddConnection(Green, yellow)
	orange.AddConnection(Blue, purple)
	orange.AddConnection(Yellow, red)
	orange.AddConnection(Magenta, red)
	orange.AddConnection(Purple, magenta)

	yellow.AddConnection(Red, orange)
	yellow.AddConnection(Cyan, green)
	yellow.AddConnection(Magenta, red)
	yellow.AddConnection(Orange, red)

	green.AddConnection(Red, yellow)
	green.AddConnection(Blue, cyan)
	green.AddConnection(Orange, yellow)
	green.AddConnection(Purple, cyan)

	cyan.AddConnection(Yellow, green)
	cyan.AddConnection(Magenta, blue)
	cyan.AddConnection(Purple, blue)

func GetElementFromName(name: String) -> ElementalType:
	# Ensure basic typos won't interfere.
	name = name.to_lower().strip_edges()
	for el in Elements:
		if el.Name.to_lower() == name:
			return el
	return null

func GetIndexFromName(name: String) -> int:
	name = name.to_lower().strip_edges()
	for i in range(len(Elements)):
		if Elements[i].Name.to_lower() == name:
			return i
	return -1

func GetMatchup(element1: ElementalType, element2: ElementalType) -> ElementalType:
	if(element1.Name == "Blank" || element2.Name == "Blank"): return null

	var node = matchups[element1.Name]
	var res = node.GetResult(element2)
	return res

func GetSideEffect(a: ElementalType, b: ElementalType):
	if(a == Blank || b == Blank): return [null, null]
	return matchups[a.Name].GetEffect(b)

func GetAllMatchups():
	var output = []
	for node in matchups.values():
		for el in node.Edges.keys():
			var edge = node.Edges[el]
			var item = []
			item.append(node.Element)
			item.append(el)
			item.append(edge.Result.Element)
			item.append(SideEffectToIndex(edge.BuffEffect, true))
			item.append(SideEffectToIndex(edge.DebuffEffect, false))

			output.append(item)
	return output

func SetSideEffectFor(a: ElementalType, b: ElementalType, index: int, isBuff: bool) -> void:
	var effect
	if index == -1:
		effect = null
	else:
		effect = BuffEffects[index] if isBuff else DebuffEffects[index]
	matchups[a.Name].SetEffect(b, effect, isBuff)

	var effects = matchups[a.Name].GetEffect(b)
	var msg1 = effects[0].Name if effects[0] != null else "null"
	var msg2 = effects[1].Name if effects[1] != null else "null"

	print("Set side effect: %s & %s = %s, %s" % [a.Name, b.Name, msg1, msg2])

func SideEffectToIndex(effect: AttackEffect, isBuff: bool) -> int:
	if(effect == null): return -1
	var effects = BuffEffects if isBuff else DebuffEffects

	for i in range(len(effects)):
		if effect == effects[i]:
			return i
	return -1

func SaveAsCSV()-> String:
	var output= []
	for node in matchups.values():
		for val in node.Edges:
			var el = val[0]
			var edge = val[1]
			var line = "%s,%s,%s,%s,%s" % [ node.Element.Name, el.Name, edge.Result.Element.Name, str(SideEffectToIndex(edge.BuffEffect, true)), str(SideEffectToIndex(edge.DebuffEffect, false)) ]
			output.append(line)
	return "\n".join(output)

func LoadFromCSV(data: String) -> void:
	var lines = data.split("\n")

	var i = -1
	for line in lines:
		i += 1
		var values = line.split(",")
		if(len(values) == 1): continue
		var a = GetElementFromName(values[0]) 
		var b = GetElementFromName(values[1])

		var buffIndex = values[3].to_int()
		SetSideEffectFor(a, b, buffIndex, true)

		var debuffIndex = values[4].to_int()
		SetSideEffectFor(a, b, debuffIndex, false)

func LoadFromDefaultCSV()-> void:
	var file = FileAccess.open(DEFAULT_CSV_PATH, FileAccess.ModeFlags.READ)
	var data = file.get_as_text()
	LoadFromCSV(data)

class ElementalNode:
	var Element : ElementalType = ElementManager.Blank
	# Dict<ElementalType, Edge>
	var Edges = {}

	func _init(element: ElementalType):
		Element = element
	
	func AddConnection(element: ElementalType, result: ElementalNode) -> void:
		Edges[element] = Edge.new(null, null, result)
	# 
	# func AddConnection(element: ElementalType, buffEffect: AttackEffect, debuffEffect: AttackEffect, result: Node) -> void:
	# 	Edges.Add(element, new Edge(buffEffect, debuffEffect, result))
	# }
	func GetResult(other: ElementalType) -> ElementalType:
		var edge = Edges.get(other, null)
		if(edge == null): return null
		return edge.Result.Element
	
	func GetEffect(other: ElementalType):
		var edge = Edges.get(other, null)
		if(edge == null): return [null, null]
		return [edge.BuffEffect, edge.DebuffEffect]
	
	func SetEffect(other: ElementalType, effect: AttackEffect, isBuff: bool) -> void:
		if(isBuff): Edges[other].BuffEffect = effect
		else: Edges[other].DebuffEffect = effect

	## Find the edge connecting this and end, then return its effect.
	func FindEffectFor(end: ElementalType) -> AttackEffect:
		for edge in Edges.values():
			if(edge.Result.Element == end): return edge.BuffEffect
		return null

class Edge:
	var BuffEffect : AttackEffect	
	var DebuffEffect : AttackEffect 
	var Result : ElementalNode 

	func _init(buffEffect: AttackEffect, debuffEffect: AttackEffect, end: ElementalNode):
		BuffEffect = buffEffect
		DebuffEffect = debuffEffect
		Result = end
