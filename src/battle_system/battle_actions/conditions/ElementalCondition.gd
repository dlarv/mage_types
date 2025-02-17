extends Condition
class_name ElementalCondition

@export var elements: Array[ElementalType]
@export_enum("ne", "any", "all")
var operator := "any"
@export_enum("user", "target", "both")
var apply_to := "user"

#override
func check(user: BattleActor, target: BattleActor, action: BattleAction, effectiveness:=1.0) -> bool:
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
	
	var msg := "ElementalCondition: %s %s {%s} => %s." \
			% ["&".join(t), op, ",".join(elements.map(func(x): return x.name)), output]
	Logger.append_log(Logger.LogType.BATTLE, msg)
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

