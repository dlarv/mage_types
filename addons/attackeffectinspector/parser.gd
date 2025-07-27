@tool
extends Object

const Type := Token.Type

var whitespace_regex: RegEx:
	get:
		if whitespace_regex == null:
			whitespace_regex = RegEx.new()
			whitespace_regex.compile(r"\s\s*")
		return whitespace_regex
var variable_regex: RegEx:
	get:
		if variable_regex == null:
			variable_regex = RegEx.new()
			variable_regex.compile(r"^\$(-|[0-9]*)?$")
		return variable_regex
var buffer_op_regex: RegEx:
	get:
		if buffer_op_regex == null:
			buffer_op_regex = RegEx.new()
			buffer_op_regex.compile(r">[+\-*/0]?")
		return buffer_op_regex


func parse(input: String) -> Variant:
	var tokens := tokenize(input)

	return null


func tokenize(input: String) -> Array[Token]:
	input = whitespace_regex.sub(input, " ", true)
	var data := Array(input.split(" "))
	# Since pop_back is cheaper than the alternative.
	data.reverse()

	var tokens: Array[Token]
	while len(data) > 0:
		var lex: String = data.pop_back()
		var res := _parse_next_token(lex)
		if res == null:
			push_error("Unknown token '%s'" % lex)
			return []
		tokens.append(res)
	
	return tokens


func _parse_next_token(lex: String) -> Token:
	if lex.is_valid_float():
		return Token.new(Type.FLOAT, float(lex))
	elif variable_regex.search(lex):
		return Token.new(Type.VARIABLE, int(lex.substr(1)))
	elif buffer_op_regex.search(lex):
		return Token.new(Type.BUFFER_OP, lex.substr(1))

	match lex.to_lower():
		"|": return Token.new(Type.PIPE, lex)
		"mul": return Token.new(Type.MUL, lex)
		"div": return Token.new(Type.DIV, lex)
		"sub": return Token.new(Type.SUB, lex)
		"add": return Token.new(Type.ADD, lex)

	return null


# func _parse_next_expression() -> Callable:
# 	pass


# func _parse_next_cmd() -> Callable:
# 	# var cmd := data.pop_back().to_lower()
# 	pass


func _parse_next_float() -> float:
	return 0.0


func _parse_next_int() -> int:
	return 0


class Token:
	enum Type { ADD, MUL, SUB, DIV, FLOAT, VARIABLE, PIPE, BUFFER_OP }
	var type: Type
	var value: Variant

	func _init(type: Type, val:Variant=null) -> void:
		self.type = type
		self.value = val
