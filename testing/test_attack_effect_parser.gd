extends GutTest

const Parser := preload("res://addons/attackeffectinspector/parser.gd")
const Type := Parser.Type

class TestAttackEffectParser extends GutTest:
	func test_tokenizer() -> void:
		var parser := Parser.new()
		var tokens := parser.tokenize("ADD MUL DIV SUB |")
		assert_eq(tokens[0].type, Type.ADD)
		assert_eq(tokens[1].type, Type.MUL)
		assert_eq(tokens[2].type, Type.DIV)
		assert_eq(tokens[3].type, Type.SUB)
		assert_eq(tokens[4].type, Type.PIPE)


	func test_tokenizer_float() -> void:
		var parser := Parser.new()
		var tokens := parser.tokenize("0 1.1 -1. .0")
		
		for token in tokens:
			assert_eq(token.type, Type.FLOAT)


	func test_tokenizer_variables() -> void:
		var parser := Parser.new()
		var tokens := parser.tokenize("$ $- $9 $100")

		for token in tokens:
			assert_eq(token.type, Type.VARIABLE)

		assert_eq(tokens[-1].value, 100)


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


