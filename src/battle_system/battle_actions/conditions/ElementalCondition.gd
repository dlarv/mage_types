@tool
extends Condition
class_name ElementalCondition

@export var elements: Array[ElementalType]
@export_enum("ne", "any", "all")
var operator := "any"
@export_enum("user", "target", "both")
var apply_to := "user"

#override
func check(user: BattleActor, target: BattleActor, effectiveness:=1.0) -> bool:
	var output := true
	var f: Callable
	var op := ""
	match operator:
		"ne": 
			f = _ne
			op = "must not contain"
		"any": 
			f = _any
			op = "must contain any"
		"all": 
			f = _all
			op = "must contain all"

	var t  := []
	if apply_to == "user" or apply_to == "both":
		t.append("User(%s, %s, %s)" % [user.name, user.element1.name, user.element2.name])
		output = f.call(user)
	if apply_to == "target" or apply_to == "both":
		t.append("Target(%s, %s, %s)" % [user.name, user.element1.name, user.element2.name])
		output = output and f.call(target)
	
	var msg := "ElementalCondition: %s %s {%s} => %s." % [
		"&".join(t), 
		op, 
		",".join(elements.map(func(x: ElementalType) -> String: return x.name)), 
		output
	]
	Logger.append_battle_log(msg)
	return output

func _ne(actor: BattleActor) -> bool:
	for element in elements:
		if actor.is_element(element): return false
	return true

func _any(actor: BattleActor) -> bool:
	for element in elements:
		if actor.is_element(element): return true
	return false

func _all(actor: BattleActor) -> bool:
	for element in elements:
		if not actor.is_element(element): return false
	return true

func _to_string() -> String:
	var output := ""
	if apply_to == "user":
		output = "User "
	elif apply_to != "both":
		output = "Target "
	if apply_to == "both":
		output += "& Target "
	
	if operator == "ne":
		output += "must not be any of the following: { "
	elif operator == "any":
		output += "must be any of the following: { "
	else:
		output += "must be all of the following: { "
	
	output += "[color=%s]%s[/color]" % [ elements[0], elements[0] ]
	
	for element: ElementalType in elements.slice(1):
		output += ", [color=%s]%s[/color]" % [ element, element ]
	
	output += " }"

	return output
