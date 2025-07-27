@tool
extends Object

const Type := Token.Type
const DataBuffer := _BattleAction.DataBuffer

var whitespace_regex: RegEx:
	get:
		if whitespace_regex == null:
			whitespace_regex = RegEx.new()
			whitespace_regex.compile(r"\s\s*")
		return whitespace_regex
var buffer_op_regex: RegEx:
	get:
		if buffer_op_regex == null:
			buffer_op_regex = RegEx.new()
			buffer_op_regex.compile(r">[+\-*/0]?")
		return buffer_op_regex


## output: Callable | null
func parse(input: String) -> Variant:
	var tokens := tokenize(input)
	tokens.reverse()

	var cmds: Array[Callable] = []
	var bufferOp := func(data: DataBuffer, result: float) -> void: pass
	while len(tokens) > 0:
		var cmd := _parse_next_cmd(tokens)
		if cmd == null: return null
		cmds.append(cmd)
	
		if len(tokens) == 0: 
			break
		elif tokens[-1].type == Type.PIPE: 
			tokens.pop_back()
		elif tokens[-1].type == Type.BUFFER_OP:
			bufferOp = _parse_buffer_op(tokens.pop_back())

	var wrapper := func(data: DataBuffer, bufferOp: Callable, cmds: Array[Callable]) -> float:
		var result := data.buffer
		for cmd in cmds:
			result = cmd.call(result)
		bufferOp.call(data, result)
		return result

	wrapper = wrapper.bind(cmds).bind(bufferOp.call)
	return wrapper


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
	elif buffer_op_regex.search(lex):
		return Token.new(Type.BUFFER_OP, lex.substr(1))

	match lex.to_lower():
		"|": return Token.new(Type.PIPE)
		"$": return Token.new(Type.VARIABLE)
		"mul": return Token.new(Type.CMD, func(a: float, b: float) -> float: return a * b)
		"add": return Token.new(Type.CMD, func(a: float, b: float) -> float: return a + b)
		"sub": return Token.new(Type.CMD, func(a: float, b: float) -> float: return a - b)
		"div": return Token.new(Type.CMD, func(a: float, b: float) -> float: return a / b)

	return null


func _parse_next_cmd(tokens: Array[Token]) -> Variant:
	var token := tokens.pop_back()
	if not token or token.type != Type.CMD:
		push_error("Expected a cmd but found '%s(%s).'" % [token.type, token.value])
		return null
	var fn: Callable = token.value
	var value: float = tokens.pop_back().value
	return fn.bind(value)


func _parse_buffer_op(token: Token) -> Callable:
	match token.value:
		"*": return func(data: DataBuffer, result: float) -> void:
				data.buffer *= result
		"/": return func(data: DataBuffer, result: float) -> void:
				data.buffer /= result
		"+": return func(data: DataBuffer, result: float) -> void:
				data.buffer += result
		"-": return func(data: DataBuffer, result: float) -> void:
				data.buffer -= result
		"0": return func(data: DataBuffer, result: float) -> void:
				data.buffer = 0

	return func(data: DataBuffer, result: float) -> void: 
		data.buffer = result


class Token:
	enum Type { CMD, FLOAT, VARIABLE, PIPE, BUFFER_OP }
	var type: Type
	var value: Variant

	func _init(type: Type, val:Variant=null) -> void:
		self.type = type
		self.value = val
