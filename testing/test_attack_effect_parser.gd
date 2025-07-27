extends GutTest

const Parser := preload("res://addons/attackeffectinspector/parser.gd")
const Type := Parser.Type
const DataBuffer := _BattleAction.DataBuffer

class TestAttackEffectParser extends GutTest:
	func test_tokenizer() -> void:
		var parser := Parser.new()
		var tokens := parser.tokenize("ADD MUL DIV SUB | $")
		assert_eq(tokens[0].type, Type.CMD)
		assert_eq(tokens[1].type, Type.CMD)
		assert_eq(tokens[2].type, Type.CMD)
		assert_eq(tokens[3].type, Type.CMD)
		assert_eq(tokens[4].type, Type.PIPE)
		assert_eq(tokens[5].type, Type.VARIABLE)


	func test_tokenizer_float() -> void:
		var parser := Parser.new()
		var tokens := parser.tokenize("0 1.1 -1. .0")
		
		for token in tokens:
			assert_eq(token.type, Type.FLOAT)


	func test_tokenizer_buffer_ops() -> void:
		var parser := Parser.new()
		var tokens := parser.tokenize("> >* >- >/ >+ >0")

		for token in tokens:
			assert_eq(token.type, Type.BUFFER_OP)


	func test_tokenizer_errors() -> void:
		var parser := Parser.new()
		var tokens := parser.tokenize("      ")
		assert_eq(len(tokens), 0)

		tokens = parser.tokenize("ASDF")
		assert_eq(len(tokens), 0)


	func test_parser_no_pipes() -> void:
		var parser := Parser.new()
		var cmd: Callable = parser.parse("mul 10")
		var action := _BattleAction.new()
		var buffer := DataBuffer.new(action)
		buffer.buffer = 10
		var output: float = cmd.call(buffer)
		assert_eq(output, 100.0)


	func test_parser_multiple_pipes() -> void:
		var parser := Parser.new()
		var cmd: Callable = parser.parse("mul 10 | div 2 | sub 1 | add 6")
		var action := _BattleAction.new()
		var buffer := DataBuffer.new(action)
		buffer.buffer = 10
		var output: float = cmd.call(buffer)
		assert_eq(output, 55.0)
	

	func test_parser_buffer_op() -> void:
		var parser := Parser.new()
		var action := _BattleAction.new()
		var buffer := DataBuffer.new(action)
		buffer.buffer = 10

		var cmd: Callable = parser.parse("mul 10 >")
		var output: float = cmd.call(buffer)
		assert_eq(buffer.buffer, 100.0)

		cmd = parser.parse("div 2 >+")
		output = cmd.call(buffer)
		assert_eq(buffer.buffer, 150.0)

		cmd = parser.parse("mul 2 >-")
		output = cmd.call(buffer)
		assert_eq(buffer.buffer, -150.0)

		cmd = parser.parse("div 150 >*")
		output = cmd.call(buffer)
		assert_eq(buffer.buffer, 150.0)

		cmd = parser.parse("div 1 >/")
		output = cmd.call(buffer)
		assert_eq(buffer.buffer, 1.0)

		cmd = parser.parse("div 150 >0")
		output = cmd.call(buffer)
		assert_eq(buffer.buffer, 0.0)
