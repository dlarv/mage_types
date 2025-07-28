@tool
extends Object

const Type := Token.Type
const DataBuffer := _BattleAction.DataBuffer

static var error_func: Callable = func(_a:Variant=null,_b:Variant=null,_c:Variant=null)->float: return INF

static var whitespace_regex: RegEx:
	get:
		if whitespace_regex == null:
			whitespace_regex = RegEx.new()
			whitespace_regex.compile(r"\s\s*")
		return whitespace_regex
static var buffer_op_regex: RegEx:
	get:
		if buffer_op_regex == null:
			buffer_op_regex = RegEx.new()
			buffer_op_regex.compile(r">[+\-*/0]?")
		return buffer_op_regex
static var variable_regex: RegEx:
	get:
		if variable_regex == null:
			variable_regex = RegEx.new()
			variable_regex.compile(r"\$[dt]?")
		return variable_regex


## output: Callable | null
static func parse(input: String) -> Variant:
	var tokens := tokenize(input)
	tokens.reverse()

	var cmds: Array[Callable] = []
	var bufferOp := func(a: Callable) -> float: return a.call()
	var prevCmd = func() -> float: return _AttackEffect.current_buffer.buffer
	while len(tokens) > 0:
		var cmd: Callable
		match tokens[-1].type:
			Type.CMD: 
				cmd = _parse_expression(tokens, prevCmd)
			Type.FLOAT:
				cmd = func(result: float) -> float: return result
				cmd.bind(prevCmd)
			Type.VARIABLE:
				cmd = func(result: float) -> float: return result
				cmd.bind(prevCmd)
			Type.PIPE:
				tokens.pop_back()
				continue
			Type.BUFFER_OP:
				bufferOp = _parse_buffer_op(tokens.pop_back())
				break

		if cmd == error_func: return null
		prevCmd = cmd

	return bufferOp.bind(prevCmd)


static func tokenize(input: String) -> Array[Token]:
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


static func _parse_next_token(lex: String) -> Token:
	if lex.is_valid_float():
		return Token.new(Type.FLOAT, float(lex))
	elif buffer_op_regex.search(lex):
		return Token.new(Type.BUFFER_OP, lex.substr(1))
	elif variable_regex.search(lex):
		return Token.new(Type.VARIABLE, lex.substr(1))

	match lex.to_lower():
		"|": return Token.new(Type.PIPE)
		"mul": return Token.new(Type.CMD, func(a: Callable, b: Callable) -> float: 
			return a.call() * b.call())
		"add": return Token.new(Type.CMD, func(a: Callable, b: Callable) -> float: 
			return a.call() + b.call())
		"sub": return Token.new(Type.CMD, func(a: Callable, b: Callable) -> float: 
			return a.call() - b.call())
		"div": return Token.new(Type.CMD, func(a: Callable, b: Callable) -> float: 
			return a.call() / b.call())
	return null


static func _parse_expression(tokens: Array[Token], prevExpression: Callable) -> Callable:
	var token := tokens.pop_back()
	if not token or token.type != Type.CMD:
		push_error("Expected a cmd but found '%s(%s).'" % [token.type, token.value])
		return error_func
	var fn: Callable = token.value

	# Parse value(s) 
	var valueA: Token = tokens.pop_back()
	var valueB: Token = tokens.pop_back() if len(tokens) > 0 and _is_value(tokens[-1]) \
			else null

	if valueB == null:
		fn = fn.bind(_parse_value(valueA)).bind(prevExpression)
	elif valueA.type == Type.VARIABLE and valueA.value == "":
		fn = fn.bind(_parse_value(valueB)).bind(prevExpression)
	else:
		fn = fn.bind(_parse_value(valueB)).bind(_parse_value(valueA))

	return fn


static func _parse_value(token: Token) -> Callable:
	if token.type == Type.FLOAT:
		return func() -> float: return token.value
	elif token.type != Type.VARIABLE:
		push_error("Invalid token. Expected VARIABLE or FLOAT, found '%s'." % token.type)
		return error_func

	match token.value.to_lower():
		"d": return func() -> float: return _AttackEffect.current_buffer.damage
		"t": return func() -> float: return _AttackEffect.current_buffer.total_damage

	return error_func


static func _parse_buffer_op(token: Token) -> Callable:
	match token.value:
		"*": return func(result: Callable) -> float:
			var res := result.call()
			_AttackEffect.current_buffer.buffer *= res
			return res
		"/": return func(result: Callable) -> float:
			var res := result.call()
			_AttackEffect.current_buffer.buffer /= res
			return res
		"+": return func(result: Callable) -> float:
			var res := result.call()
			_AttackEffect.current_buffer.buffer += res
			return res
		"-": return func(result: Callable) -> float:
			var res := result.call()
			_AttackEffect.current_buffer.buffer -= res
			return res
		"0": return func(result: Callable) -> float:
				_AttackEffect.current_buffer.buffer = 0
				return result.call()

	return func(result: Callable) -> float: 
		var res := result.call()
		_AttackEffect.current_buffer.buffer = res
		return res


static func _is_value(token: Token) -> bool:
	return token.type in [Type.VARIABLE, Type.FLOAT]


class Token:
	enum Type { CMD, FLOAT, VARIABLE, PIPE, BUFFER_OP }
	var type: Type
	var value: Variant

	func _init(type: Type, val:Variant=null) -> void:
		self.type = type
		self.value = val
